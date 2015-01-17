class Edit

  @screenshot = (type, image_url, image_info={}) ->
    $image = new Image
    $image.src = image_url
    $image.onload = ()->
      jQuery ->
        append_canvas_html type, image_url, image_info, $image
        $image_canvas = $("#canvas-image")
        context = $image_canvas[0].getContext('2d')
        # context.scale(2,2)
        draw_image_to_canvas type, $image, image_info, context
        annotate_canvas $("#canvas-annotations")

  draw_image_to_canvas = (type, $image, image_info={}, context) ->
    if type == "visible"
      context.drawImage $image, 0, 0
    else if type == "partial"
      context.drawImage $image, image_info.x, image_info.y, image_info.w, image_info.h, 0, 0, image_info.w, image_info.h

  append_canvas_html = (type, image_url, image_info={}, $image) ->
    if type == "visible"
      $("main").append canvas_html image_url, $image.naturalWidth, $image.naturalHeight, 0, 0
    else if type == "partial"
      $("main").append canvas_html image_url, image_info.w, image_info.h, image_info.x, image_info.y

  canvas_html = (image_url, w, h, x, y) ->
    """
      <section id="editor">
        <canvas id="canvas-image" width="#{w}" height="#{h}"></canvas>
        <canvas id="canvas-annotations" width="#{w}" height="#{h}"></canvas>
      </section>

      <style>
        #editor {
          width      : #{w}px;
          height     : #{h}px;
          background : url(#{image_url}) no-repeat -#{x}px -#{y}px;
        }

        main {
          min-width: #{w+100}px;
        }
      </style>
    """

  annotate_canvas = ($canvas)->
    $canvas.annotate
      tools_container : "#header-main #annotate"
      color           : 'red'
      type            : 'rectangle'

  @save_canvas = ->
    # screenshot     = $("#canvas-image")
    # screenshot_ctx = screenshot[0].getContext("2d")
    # annotations    = $("#canvas-annotations")
    # screenshot_ctx.drawImage(annotations[0], 0, 0)
    # image          = screenshot[0].toDataURL("image/png")
    init_trello (access)->
      if access
        build_trello access

  init_trello = (callback) ->
    Trello.is_user_logged_in (username) ->
      if username
        Trello.get_api_credentials (creds) ->
          if creds
            Trello.get_client_token creds, (token) ->
              if token
                callback {username: username, creds: creds, token: token}
              else
                callback false
          else
            callback false
      else
        # show log in form
        callback false


  build_trello = (access) ->
    Trello.get_boards access, (boards) ->
      console.log boards



chrome.runtime.onMessage.addListener (message, sender, sendResponse) ->
  Edit.screenshot message.screenshot, message.image, message.image_info

jQuery ->
  $("main").css
    "min-height": $(window).innerHeight() - 70

  $("#upload").on "click", ".upload-button", ->
    Edit.save_canvas()