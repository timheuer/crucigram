#!/usr/bin/env python3
"""
generate_wordlist.py — Generates wordlist.json for Gridlet from Open English WordNet + wordfreq.

Sources:
  - Open English WordNet (ewn:2020) — provides word definitions (clues)
  - wordfreq — filters to common, well-known English words

Usage:
  pip install wordfreq wn
  python3 scripts/generate_wordlist.py

Output:
  Gridlet/Resources/wordlist.json
"""

import json
import re
import sys
from pathlib import Path
from typing import Optional

import wn
from wordfreq import word_frequency, top_n_list

# ── Configuration ──────────────────────────────────────────────────────────────

MIN_LENGTH = 3
MAX_LENGTH = 6
TARGET_COUNT = 800       # aim for this many word-clue pairs
MAX_CLUE_WORDS = 8       # max words in a clue (truncated at natural boundaries)
LANGUAGE = "en"
FREQ_LIST = "best"       # wordfreq's best-quality list

# Words to exclude (offensive, function words, etc.)
BLOCKLIST = {
    # Offensive
    "ass", "damn", "hell", "crap", "slut", "whore", "bitch", "dick", "cock",
    "shit", "fuck", "piss", "tit", "tits", "cum", "porn", "anus", "rape",
    "nazi", "aids", "die", "dies", "kill", "dead", "death", "drug", "drugs",
    "gun", "guns", "bomb", "slave", "satan", "sex", "sexy",
    # Function words / pronouns / articles (poor crossword entries)
    "the", "and", "for", "are", "but", "not", "you", "all", "can", "had",
    "her", "was", "one", "our", "out", "has", "his", "how", "its", "may",
    "did", "get", "got", "let", "say", "she", "too", "use", "who", "why",
    "also", "been", "call", "each", "from", "have", "into", "just", "like",
    "long", "make", "many", "more", "most", "much", "must", "only", "over",
    "said", "same", "some", "such", "take", "than", "that", "them", "then",
    "they", "this", "very", "what", "when", "will", "with", "your",
    "about", "after", "being", "could", "every", "first", "found", "great",
    "these", "thing", "think", "those", "under", "where", "which", "while",
    "would", "their", "there", "other", "shall", "still", "since",
    # Proper nouns that sneak through wordfreq
    "france", "africa", "china", "india", "japan", "korea", "spain",
    "texas", "paris", "london", "york", "roman",
}

# ── Helpers ────────────────────────────────────────────────────────────────────

def is_valid_word(word: str) -> bool:
    """Check if a word is suitable for crossword use."""
    w = word.lower()
    if len(w) < MIN_LENGTH or len(w) > MAX_LENGTH:
        return False
    if not re.match(r'^[a-z]+$', w):
        return False  # no hyphens, spaces, apostrophes
    if w in BLOCKLIST:
        return False
    return True


def clean_definition(definition: str) -> str:
    """Trim a WordNet definition into a concise crossword-style clue."""
    # Remove parenthetical remarks
    clue = re.sub(r'\([^)]*\)', '', definition)
    # Remove quotes
    clue = re.sub(r'["\']', '', clue)
    # Remove leading articles for brevity
    clue = re.sub(r'^(a |an |the )', '', clue.strip(), flags=re.IGNORECASE)
    # Collapse whitespace
    clue = ' '.join(clue.split())
    # Capitalize first letter
    clue = clue.strip()
    if clue:
        clue = clue[0].upper() + clue[1:]
    # Truncate at a natural boundary (semicolon, comma, or "or" clause) if too long
    # First, try splitting at semicolons
    if ';' in clue:
        clue = clue.split(';')[0].strip()
    # Then try splitting at " or " if still long
    words = clue.split()
    if len(words) > MAX_CLUE_WORDS and ' or ' in clue:
        clue = clue.split(' or ')[0].strip()
    # Truncate to MAX_CLUE_WORDS but only at a natural word boundary
    # (avoid cutting after articles, prepositions, conjunctions)
    words = clue.split()
    if len(words) > MAX_CLUE_WORDS:
        stop_words = {'a','an','the','of','to','in','for','on','at','by','or','and',
                       'with','as','from','that','is','it','its','into','not','be',
                       'no','so','if','than','but','up','out','some','how'}
        # Find the best cut point at or before MAX_CLUE_WORDS
        cut = MAX_CLUE_WORDS
        while cut > 3 and words[cut - 1].lower().rstrip('.,;:') in stop_words:
            cut -= 1
        clue = ' '.join(words[:cut])
    # Remove trailing punctuation artifacts
    clue = clue.rstrip(' ;,.:')
    return clue


def get_best_clue(word: str, wordnet_en) -> Optional[str]:
    """Get the best definition from WordNet — prefers the first (most common) sense."""
    senses = wordnet_en.senses(word.lower())
    if not senses:
        return None

    candidates = []

    for i, sense in enumerate(senses):
        synset = sense.synset()
        defn = synset.definition()
        if not defn:
            continue

        cleaned = clean_definition(defn)
        if not cleaned or len(cleaned) < 3:
            continue

        # Don't use clues that contain the answer word
        if word.lower() in cleaned.lower().split():
            continue

        # Skip inappropriate or overly clinical definitions
        inappropriate = ['sexual', 'intercourse', 'genitals', 'excrement', 'urinate', 'defecate']
        if any(bad in cleaned.lower() for bad in inappropriate):
            continue

        # Score: strongly prefer first sense (most common meaning)
        # Lower score = better
        length_penalty = max(0, len(cleaned) - 50) * 0.5
        sense_rank = i * 50  # very strong preference for first sense
        score = sense_rank + length_penalty
        candidates.append((score, cleaned))

    if not candidates:
        return None

    candidates.sort(key=lambda x: x[0])
    return candidates[0][1]


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    print("Loading Open English WordNet...")
    wordnet_en = wn.Wordnet("ewn:2020")

    print("Getting common English words from wordfreq...")
    # Get top N most frequent English words
    common_words = top_n_list(LANGUAGE, 8000, wordlist=FREQ_LIST)

    # Filter to valid crossword words
    candidates = [w for w in common_words if is_valid_word(w)]
    print(f"  {len(candidates)} candidate words after filtering (length {MIN_LENGTH}-{MAX_LENGTH}, alpha-only)")

    results = []
    skipped_no_clue = 0

    for word in candidates:
        if len(results) >= TARGET_COUNT:
            break

        clue = get_best_clue(word, wordnet_en)
        if clue:
            results.append({
                "word": word.upper(),
                "clue": clue
            })
        else:
            skipped_no_clue += 1

    # Sort alphabetically for readability
    results.sort(key=lambda x: x["word"])

    # Write output
    output_path = Path(__file__).parent.parent / "Gridlet" / "Resources" / "wordlist.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, "w") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print(f"\nGenerated {len(results)} word-clue pairs → {output_path}")
    print(f"Skipped {skipped_no_clue} words (no suitable clue found)")

    # Print some stats
    lengths = {}
    for entry in results:
        l = len(entry["word"])
        lengths[l] = lengths.get(l, 0) + 1
    print("\nBy word length:")
    for l in sorted(lengths):
        print(f"  {l} letters: {lengths[l]} words")


if __name__ == "__main__":
    main()
