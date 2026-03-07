import { QuartzEmitterPlugin } from "../types"
import { write } from "./helpers"
import { FullSlug } from "../../util/path"
import { JSX } from "preact"

function sanitizePublisherId(publisherId: string): string {
  return publisherId.trim()
}

function buildAdSenseScript(publisherId: string): JSX.Element {
  const client = encodeURIComponent(publisherId)
  return (
    <script
      async
      src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${client}`}
      crossOrigin="anonymous"
    />
  )
}

export const AdSense: QuartzEmitterPlugin = () => ({
  name: "AdSense",
  externalResources(ctx) {
    const adsense = ctx.cfg.configuration.adsense
    if (!adsense?.enabled) {
      return {}
    }

    const publisherId = sanitizePublisherId(adsense.publisherId)
    if (!publisherId) {
      return {}
    }

    return {
      additionalHead: [buildAdSenseScript(publisherId)],
    }
  },
  async emit(ctx) {
    const adsense = ctx.cfg.configuration.adsense
    if (!adsense?.adsTxtEnabled) {
      return []
    }

    const lines = adsense.adsTxtLines
      .map((line) => line.trim())
      .filter((line) => line.length > 0)

    if (lines.length === 0) {
      return []
    }

    const path = await write({
      ctx,
      content: lines.join("\n") + "\n",
      slug: "ads" as FullSlug,
      ext: ".txt",
    })

    return [path]
  },
  async *partialEmit() {},
})
