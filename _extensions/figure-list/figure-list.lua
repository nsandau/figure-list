-- Using identifier instead of classes as there should only be one instance
-- [[ # List of figures
-- ::: {#figurelist}
-- :::
-- ]]
-- YAML
--    - at: post-render
--      path: "src/utils/filters/figure-list.lua"
-- figurelist:
--     only_captions: true
-- #TODO: insert images together with captions
-- # TODO: It seems the figure and captions are in a pandoc.Table block?

stringify = pandoc.utils.stringify

local figures = {}
local captions = {}
only_captions = false

function Meta(meta)
    if meta.figurelist and meta.figurelist.only_captions then
        only_captions = meta.figurelist.only_captions
    end
end

-- # Nedenstående er når man kører pre-render hvor det endnu ikke er lavet til Table endnu
-- function Image(img)
--     table.insert(figures, img)
--     return {}
-- end
--
-- function FloatRefTarget(ref)
--     if ref.type == "Figure" then
--         local caption_text = pandoc.utils.stringify(ref.caption_long)
--         table.insert(captions, caption_text)
--         return {}
--     end
-- end

function is_image(el)
    if el.identifier then
        is_figure = string.find(el.identifier, "^fig-") ~= nil
    end
end

function Table(tbl)
    local id = tbl.bodies[1].body[1].cells[1].contents[1].identifier

    -- extract image
    if id:find("^fig-") ~= nil then
        table.insert(figures, tbl)

        -- # TODO: Jeg mister formatting ved at bruge stringify
        -- I stedet kunne jeg loope over div content og kun tilføje det der ikke er rawblocks ?

        table.insert(captions, stringify(tbl.bodies[1].body[1].cells[1].contents[1].content[2]))


        return {}
    end

    -- extract caption

    -- for i, cell in ipairs(tbl.bodies[1].body[1].cells[1].contents[1].content[2]) do
    --     quarto.log.output(cell)
    -- end
    -- quarto.log.output(figures)
    -- for _, cell in ipairs(cells.contents) do
    --     quarto.log.output(cell.identifier)
    -- end
end

function Div(div)
    if div.identifier == 'figurelist' then
        if only_captions then
            local captions_para = pandoc.Para({})
            for i, caption in ipairs(captions) do
                table.insert(captions_para.content, pandoc.Str(caption))
                table.insert(captions_para.content, pandoc.LineBreak())
                table.insert(captions_para.content, pandoc.LineBreak())
            end
            return captions_para
        else
            local figures_div = pandoc.Div(figures)
            return figures_div
        end
    end
end

return {
    { Meta = Meta },
    { Table = Table },
    { Div = Div },
}
