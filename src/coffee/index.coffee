# main object for storing state/whatever
Pynia = {
  histogramArea:
    height: 181
    width: 600
    x: 0
    y: 0
  spectographArea:
    height: 141
    width: 160
    x: 0
    y: 210
  frequencyGraphArea:
    height: 141
    width: 410
    x: 190
    y: 210
  frequencyRangePrefixes: [
    " 06-09hz => ",
    " 09-12hz => ",
    " 12-15hz => ",
    " 15-20hz => ",
    " 20-25hz => ",
    " 25-30hz => "
  ]
  stepImage: new Image()
}

Pynia.stepImage.src = "/static/images/step.png"

$(document).ready ->
  # add canvas for steps
  Pynia.canvas = $("#canvas")[0]
  Pynia.context = Pynia.canvas.getContext("2d")

  # set up a helper to draw the background
  Pynia.drawBackground = ->
    # fill background color
    Pynia.context.beginPath()
    Pynia.context.fillStyle = "#000630"
    Pynia.context.rect(
      Pynia.histogramArea.x,
      Pynia.histogramArea.y,
      Pynia.histogramArea.width,
      Pynia.histogramArea.height)
    Pynia.context.fill()

    Pynia.context.beginPath()
    Pynia.context.fillStyle = "white"
    Pynia.context.rect(
      Pynia.spectographArea.x,
      Pynia.spectographArea.y,
      Pynia.spectographArea.width,
      Pynia.spectographArea.height)
    Pynia.context.fill()

    Pynia.context.beginPath()
    Pynia.context.fillStyle = "white"
    Pynia.context.rect(
      Pynia.frequencyGraphArea.x,
      Pynia.frequencyGraphArea.y,
      Pynia.frequencyGraphArea.width,
      Pynia.frequencyGraphArea.height)
    Pynia.context.fill()

  Pynia.updateLoop = ->
    $.ajax
      url: "/get_steps"
      success: (response) ->
        $("#console").html("")

        # clear the canvas
        Pynia.drawBackground()

        # draw integer scale steps for each frequency range as a histogram
        _.each response.brain_fingers, (it, idx) ->
          $("#console").append("#{Pynia.frequencyRangePrefixes[idx]} #{it}\n")

          if it > 0
            for height in [1..it]
              Pynia.context.drawImage(
                Pynia.stepImage,
                idx * 50 + 160,
                height * -15 + 170)

        # base64 decode the RGB waveform and draw it
        waveformRGB = atob(response.waveform)
        waveform = Pynia.context.createImageData(410,140)
        for i in [0..410]
          for j in [0..140] by 3
            r = parseInt(waveformRGB[i*j]) >> 16
            if isNaN(r)
              r = 0
            waveform.data[i*j] = r
            g = parseInt(waveformRGB[i*j+1]) >> 8
            if isNaN(g)
              g = 0
            waveform.data[i*j+1] = g
            b = parseInt(waveformRGB[i*j+2])
            if isNaN(b)
              b = 0
            waveform.data[i*j+2] = b

        sample = Pynia.context.getImageData(0, 0, 15, 15)
        Pynia.context.putImageData(
          waveform,
          Pynia.frequencyGraphArea.x,
          Pynia.frequencyGraphArea.y)

        # redraw
        setTimeout ->
          Pynia.updateLoop()
        , 50

  Pynia.updateLoop()
