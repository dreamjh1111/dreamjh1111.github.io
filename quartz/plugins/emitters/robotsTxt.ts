import { QuartzEmitterPlugin } from "../types"
import { write } from "./helpers"
import { FullSlug } from "../../util/path"

export const RobotsTxt: QuartzEmitterPlugin = () => ({
  name: "RobotsTxt",
  async emit(ctx) {
    const baseUrl = ctx.cfg.configuration.baseUrl ?? ""
    const content = [
      "User-agent: *",
      "Allow: /",
      "",
      "User-agent: Yeti",
      "Allow: /",
      "",
      `Sitemap: https://${baseUrl}/sitemap.xml`,
    ].join("\n")

    const path = await write({
      ctx,
      content,
      slug: "robots" as FullSlug,
      ext: ".txt",
    })
    return [path]
  },
  async *partialEmit() {},
})
