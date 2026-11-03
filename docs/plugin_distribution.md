# Plugin distribution maintenance

The authoritative source is this repository's addons/simple_inventory directory. The plugin-only repository is https://github.com/LiGameAcademy/laoli_simple_inventory . It is not a second place for independent feature edits.

## First snapshot

Source PR #1 integrated b12c2c512c2e95e2a6cb91ce2c2e03906a9fba35. Its plugin tree is a1f4ca58d90c9004e8d30a7932984bc1143f0b95. Distribution commit 00c25ce10b63961c3bded671c3f843d257b24341 has that identical tree, including notices and standalone contracts. The full source/teaching history remains here; the new distribution begins with the approved snapshot rather than inheriting removed unverified assets from old commits.

## Updates

1. Modify addons/simple_inventory and related source tests on a source PR. Run tools/run_checks.py, relevant lifecycle checks and independent review, then merge under master protection.
2. Derive the root plugin tree using git subtree split --prefix=addons/simple_inventory, or export it with git archive HEAD:addons/simple_inventory. Do not import the complete teaching repository into a host addon path.
3. Apply that exact current tree on a clean distribution feature branch, preserving its existing history. Include the source commit in the commit message. Do not force-push or replace existing distribution history. Verify the staged/committed root tree equals the source plugin subtree with git rev-parse; all files, including plugin.uid, belong to the tree.
4. Run the distribution's tools/run_tests.py in its own checkout and open a distribution PR. The required Inventory contracts check must pass before merging. Tag only validated commits; do not move existing tags.
5. Update host gitlinks explicitly, run real host regressions and merge their PRs. Update tutorial version records last. No silent dependency upgrades or manual edits inside a host's checked-out plugin.

The plugin root contains its own CI workflow. Source-only documentation updates do not require a new distribution snapshot if the plugin tree is unchanged. Runtime and visual validation have separate scopes; fresh install and recursive-checkout evidence must use the selected dependency commit.
