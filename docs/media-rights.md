# Media Rights

## Fork status

This fork removes every media file that upstream identifies as outside the MIT
license:

- `docs/media/github-cover.jpg` was removed
- `ripple/Assets.xcassets/image_2.imageset/image-2.jpg` was removed
- `ripple/Assets.xcassets/palm_tree.imageset/image.png` was replaced

The current runtime assets are:

- `ripple/Assets.xcassets/palm_tree.imageset/image.png`
- `ripple/Assets.xcassets/image_2.imageset/image-2.png`

They are replacement abstract images generated specifically for this fork on
2026-07-26. No source images were supplied to the generation tool. Their exact
prompts, timestamps, output identifiers, dimensions, and SHA256 hashes are in
[`media/provenance.json`](./media/provenance.json).

`docs/media/memi-simulator-proof.jpg`,
`docs/media/memi-reduced-motion-before.jpg`, and
`docs/media/memi-reduced-motion-after.jpg` are simulator screenshots of the
fork using replacement assets. They are retained as documentation evidence and
include Apple simulator chrome; this repository does not grant rights it does
not hold in third-party interface elements.

## License basis and limits

The fork maintainer offers the two generated replacement images under the MIT
license in [`LICENSE`](../LICENSE). The stated basis is the output-assignment
language in the OpenAI agreement applicable to the account that requested the
images:

- [Terms of Use, Content](https://openai.com/policies/terms-of-use/)
- [OpenAI Services Agreement, Customer Content](https://openai.com/policies/services-agreement/)

This repository record does not establish which of those agreements governed
the generating account. It also does not independently prove copyrightability,
uniqueness, or absence of third-party rights. The hashes and prompts make the
generation event auditable without expanding that claim.

## Upstream attribution

The application source remains derived from
[`eujinco/ripple-image-transitions`](https://github.com/eujinco/ripple-image-transitions).
The original copyright and MIT terms remain intact in
[`LICENSE`](../LICENSE). The separate [`NOTICE.md`](../NOTICE.md) records the
fork boundary without implying upstream affiliation or endorsement.
