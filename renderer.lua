--- A renderer library for ease of use
--- renderer.* functions are only available in render callbacks
--- A render loop can be created by doing renderer.add_callback(f: function)

--- @field add_callback fun(f: function, identifier: string|nil)
renderer = {}

local renderer_callbacks = {}
local cached_drawings = {}
local last_frame_drawings = {}

--- @param class_name string | "'Rectangle'" | "'Line'" | "'Circle'" | "'Square'" | "'Triangle'" | "'Text'"
--- @param properties DrawingObject
local function create_drawing(class_name, properties)
    local temporary_drawing = Drawing.new(class_name)

    for k, v in next, properties do
        temporary_drawing[k] = v
    end

    return temporary_drawing
end

function renderer.add_callback(f, identifier)
    if identifier then
        renderer_callbacks[identifier] = f
    else
        renderer_callbacks:insert(f)
    end
end
function renderer.rectangle(x, y, w, h, r, g, b, a)
    if syn then
        table.insert(cached_drawings, create_drawing('Square', {
            Size = Vector2.new(w, h),
            Position = Vector2.new(x, y),
            Color = Color3.fromRGB(r, g, b),
            Transparency = a / 255,
            Visible = true
        }))
    else
        table.insert(cached_drawings, create_drawing('Rectangle', {
            Size = Vector2.new(w, h),
            Position = Vector2.new(x, y),
            Color = Color3.fromRGB(r, g, b),
            Transparency = a / 255,
            Visible = true
        }))
    end
end

game:GetService("RunService"):BindToRenderStep("renderer", 1, function()
    --// Put the last drawings into the correct table
    last_frame_drawings = cached_drawings

    --// Call the rendering callbacks
    for k, v in next, renderer_callbacks do
        xpcall(v, function(err)
            print( string.format('renderer function %s: %s', k, err) )
        end)
    end

    --// Remove the last frame drawing (do this last so it doesn't look jittery)
    for k, v in next, last_frame_drawings do
        v:Remove()
    end
end)

return renderer
