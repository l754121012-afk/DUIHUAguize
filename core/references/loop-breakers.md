# Loop Breakers

Stop the current attempt when:

- the same failure repeats twice;
- two consecutive tool cycles produce no new evidence;
- the same assumption is retried without a new check;
- a plan is being rewritten repeatedly;
- a context compaction occurs;
- budget exceeds 150% without validation progress.

After stopping:

1. Write confirmed facts.
2. Write rejected hypotheses and evidence.
3. Define the smallest next check.
4. Update handoff if the milestone cannot finish.

