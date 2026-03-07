import { QuartzEmitterPlugin } from "../types"
import { JSX } from "preact"

interface SearchConsoleMetaTagOptions {
  enabled: boolean
  content: string
}

const defaultOptions: SearchConsoleMetaTagOptions = {
  enabled: true,
  content: "",
}

function buildMetaTag(content: string): JSX.Element {
  return <meta name="google-site-verification" content={content} />
}

export const SearchConsoleMetaTag: QuartzEmitterPlugin<
  Partial<SearchConsoleMetaTagOptions>
> = (userOpts) => {
  const opts = { ...defaultOptions, ...userOpts }

  return {
    name: "SearchConsoleMetaTag",
    externalResources() {
      const content = opts.content.trim()
      if (!opts.enabled || content.length === 0) {
        return {}
      }

      return {
        additionalHead: [buildMetaTag(content)],
      }
    },
    async emit() {
      return []
    },
    async *partialEmit() {},
  }
}
