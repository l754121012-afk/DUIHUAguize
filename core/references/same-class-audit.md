# Same-Class Audit

After fixing one bug, omission or inconsistency:

1. Identify the root-cause pattern.
2. Search sibling modules, races, card types, event cases, adapters or state fields that share the pattern.
3. Classify findings as:
   - actual same-root-cause issue;
   - checked and currently safe;
   - explicit deferred exception.
4. Add at least one representative test beyond the original example.
5. Report the audit scope, found count, fixed count and deferred items.

A single example passing is not evidence that the class is fixed.

