# Janngu Fulfulde 1

A Fulfulde literacy course for children, built as a single HTML file that runs in any
browser — on a phone, on a laptop, online or off.

The course is aimed at diaspora children who do **not** already speak Fulfulde, rather
than at heritage speakers learning to read a language they already know. It is based on
the printed primer *JANNGU (I)* by Amadu Sajoh Bah (Peeral), and follows his Guinea /
Fuuta Jaloo orthography (32 letters) rather than the ACALAN pan-Fulfulde standard.

## Opening it

Open `index.html` in a browser, or visit the published site. Nothing to install.

Fonts are embedded in the file, so the course renders correctly with no network
connection. The only external assets are the sound clips in `audio/`.

## What's in here

```
index.html      the current build
v177.html       the same build, kept under its own number
v176.html …     earlier builds, still openable
audio/          sound clips, loaded by relative path
  letters/      letter sounds and names
  words/        vocabulary, four forms per word
  phr/          marker phrases (baafal ngal, ngal baafal)
  markers/      the little words on their own
  num/          numbers
  syl/          syllables
  pairs/        short and long vowel pairs
  days/         days of the week
```

`audio/` must sit beside whichever HTML file is being opened — the paths inside the
build are relative. Filenames are case-sensitive once hosted.

## How the course is laid out

Five region worlds (the Fuutas), each a road of stops. The learner's traveller is flown
between stops by helicopter, and the road draws itself under the flight. Stops teach, in
turn: letters and their sounds, vowel length, vocabulary, the noun-class markers
(*ngal, ngel, koy, ɗee* and their families), and sentence building.

Progress is saved to the device and resumes where the learner left off. Each saved place
is stamped with the build that wrote it, so places written by an older build are dropped
rather than resuming a learner past screens that have since changed.

## Versions

- `index.html` is always the current build.
- Every build is also kept under its own number, `vNNN.html`.
- **A rebuild never reuses a lost build's number.** Where a build was lost before it
  could be saved, the course was rebuilt forward from the last surviving file and given
  the *next* number — so v33 → v38, v63 → v65, v126 → v129, v153 → v155. This means a
  gap in the numbering is deliberate and a number always identifies one file only.

## Language

The course carries no English instructions. What a child sees is Fulfulde, numerals and
pictures; the English explanation of what to do at each stage lives in the grown-ups'
drawer, behind a press-and-hold gate. Word glosses are still English and are due to be
reconsidered — most of the intended audience reads French first.

Place names are written in Pular (Maamu, Labe, Tugee, Yemberen, Dugun), not in French
spelling.

## Known gaps

- Spoken instruction clips do not yet exist, so the course is adult-mediated for now:
  a grown-up reads the stage instruction from the drawer.
- Some phrase and marker recordings referenced by the build are still missing.
- The vocabulary swap — replacing primer nouns that are not everyday words for diaspora
  children — is in progress and being checked with family in Guinea.

## Credit

Course content derives from the primers of **Amadu Sajoh Bah (Peeral)**, with reference
to Oumar Bah's *Lexique de terminologie générale fulfulde-français-anglais* (2010) and
*Dictionnaire Pular* (SIL Webonary, fuf-GN).
