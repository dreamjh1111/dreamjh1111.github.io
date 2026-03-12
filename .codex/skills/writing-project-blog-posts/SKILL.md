---
name: writing-project-blog-posts
description: Use when writing, revising, or researching blog posts for this Quartz project, especially for files under content/ that require external topic research, visual assets, and publish-ready Markdown.
---

# Writing Project Blog Posts

## Overview

Write blog posts for this project only after external topic research and with local visual assets that can be committed with the post.

## Workflow

1. Research before drafting.
   Review about 10 topic-relevant posts across `velog`, `tistory`, and `reddit` before writing.
   Prefer sources with visible high view counts. If exact views are not visible, use strong engagement signals such as upvotes, likes, comments, bookmarks, or strong search prominence as a fallback.
2. Draft from the strongest references.
   Use the high-performing references to organize the article, identify recurring reader questions, and find gaps to improve.
   Do not copy wording or structure too closely. Rewrite in this project's own voice and improve clarity.
3. Add visuals, not just prose.
   Use images or screenshots when they materially improve understanding.
   Use Mermaid diagrams when the topic involves flows, state transitions, ranges, locking behavior, architecture, or step-by-step processes.
4. Store images locally.
   Never hotlink images in the final Markdown.
   Download each image first, save it under `content/attachfiles/`, and link the local file in the post.
   Prefer descriptive filenames tied to the article topic rather than generic pasted names when practical.
5. Final output must be repository-ready.
   Ensure every image reference points to a local file under `content/attachfiles/`.
   Ensure the post contains at least one meaningful visual aid when the topic benefits from it.

## Non-Negotiables

- Do not draft from memory alone before the external research pass.
- Do not skip the `velog`, `tistory`, `reddit` survey unless the human explicitly narrows the rule.
- Do not prioritize low-signal references when higher-traffic or higher-engagement references are available.
- Do not leave external image URLs embedded in the final Markdown.
- Do not attach remote image links when the same asset can be downloaded and stored locally.

## Quick Checklist

- Reviewed about 10 relevant external posts
- Preferred high-view or high-engagement references
- Drafted from synthesized notes, not copied prose
- Added Mermaid and/or images where they clarify the topic
- Saved image assets in `content/attachfiles/`
- Linked local files instead of remote image URLs
