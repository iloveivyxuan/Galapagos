window.Widgets =
  widgets: []
  widgetUpdateFuncs: []
  sliderUpdateFuncs: []
  addTo: (session) ->
    for widget in @widgets
      widget(session)
  runUpdateFuncs: () ->
    func() for func in @widgetUpdateFuncs
    func() for func in @sliderUpdateFuncs   # Do slider updates separately because they may depend on other sliders FD 2/7/13
  setDimensions: (e, left, top, right, bottom) ->
    e.style.width = right - left
    e.style.height = bottom - top
    e.style.top = top
    e.style.left = left
  addButton: (display, left, top, right, bottom, code, forever) ->
    escapedDisplay = display.replace("'", "\\'")
    @widgets.push((session) =>
      button = session.container.querySelector("button[netlogo-display='#{escapedDisplay}']")
      if not button?
        button = document.createElement('button')
        button.setAttribute('netlogo-display', display) # setAttribute handles escaping
        button.style.position = "absolute"
        button.style.fontSize = "8pt"
        @setDimensions(button, left, top, right, bottom)
        session.container.appendChild(button)

      button.innerHTML = display +
        if forever then " (Off)" else ""
      if forever
        running = false
        button.addEventListener("click",(() ->
          running = !running
          button.innerHTML = display +
            if running then " (On)" else " (Off)"))
        @widgetUpdateFuncs.push((() -> if running then code()))
      else
        button.addEventListener("click", code)
    )
  addSlider: (display, left, top, right, bottom, setter, min, max, def, step) ->
    escapedDisplay = display.replace("'", "\\'")
    @widgets.push((session) =>
      input = session.container.querySelector(
        "input[type=range][netlogo-display='#{escapedDisplay}']")
      if not input?
        slider = document.createElement('div')
        slider.style.position = "absolute"
        slider.style.fontSize = "8pt"
        @setDimensions(slider, left, top, right, bottom)

        valueLabel = document.createElement('label')
        valueLabel.innerHTML = def
        valueLabel.style.cssFloat = "right"

        input = document.createElement('input')
        input.setAttribute('netlogo-display', display) # setAttribute handles escaping
        input.type = "range"
        if typeof(max) == 'function'
          input.max = max()
          @sliderUpdateFuncs.push((() -> input.max = max()))
        else
          input.max = max

        if typeof(min) == 'function'
          input.min = min()
          @sliderUpdateFuncs.push((() -> input.min = min()))
        else
          input.min = min

        if typeof(step) == 'function'
          input.step = step()
          @sliderUpdateFuncs.push((() -> input.step = step()))
        else
        input.step = step
        input.style.width = "100%"

        label = document.createElement('label')
        label.innerHTML = display

        slider.appendChild(input)
        slider.appendChild(valueLabel)
        slider.appendChild(label)
        session.container.appendChild(slider)

      update = () ->
        if valueLabel == undefined
          valueLabel = (if input.id.length > 0 then session.container.queryElement("label[for='#{input.id}']")) or (if input.parentElement.tagName == 'LABEL' then input.parentElement)
        if valueLabel != undefined
          valueLabel.innerHTML = input.value
        setter(parseInt(input.value))
      input.value = def
      input.addEventListener("input", update)
    )

  addSwitch: (display, left, top, right, bottom, setter) ->
    escapedDisplay = display.replace("'", "\\'")
    @widgets.push((session) =>
      input = session.container.querySelector(
        "input[type='checkbox'][netlogo-display='#{escapedDisplay}']")

      if not input?
        swtch = document.createElement('div')
        swtch.style.position = "absolute"
        swtch.style.fontSize = "8pt"
        @setDimensions(swtch, left, top, right, bottom)

        input = document.createElement('input')
        input.setAttribute('netlogo-display', display) # setAttribute handles escaping
        input.type = "checkbox"
        input.style.cssFloat = "left"

        label = document.createElement('label')
        label.innerHTML = display

        swtch.appendChild(input)
        swtch.appendChild(label)
        session.container.appendChild(swtch)

      input.onchange = () ->
        setter(input.checked)
    )

  addMonitor: (display, left, top, right, bottom, code) ->
    escapedDisplay = display.replace("'", "\\'")
    @widgets.push((session) =>
      value = session.container.querySelector("div[netlogo-display='#{escapedDisplay}']")
      if not value?
        monitor = document.createElement('div')
        monitor.style.position = "absolute"
        monitor.style.fontSize = "8pt"
        monitor.style.backgroundColor = "#CCCCCC"
        @setDimensions(monitor, left, top, right, bottom)

        heading = document.createElement('label')
        heading.style.margin = 4
        heading.innerHTML = display
        heading.style.position = "relative"

        value = document.createElement('div')
        value.setAttribute('netlogo-display', display) # setAttribute handles escaping
        value.style.backgroundColor = "white"
        value.style.position = "relative"
        value.style.margin = 4
        value.style.padding = 2

        monitor.appendChild(heading)
        monitor.appendChild(value)
        session.container.appendChild(monitor)

      value.innerHTML = "0"
      @widgetUpdateFuncs.push((() -> value.innerHTML = code()))
    )
  addTextBox: (display, left, top, right, bottom) ->
    escapedDisplay = display.replace("'", "\\'")
    @widgets.push((session) =>
      textBox = session.container.querySelector("div[netlogo-display='#{escapedDisplay}']")
      if not textBox?
        textBox = document.createElement('div')
        textBox.setAttribute('netlogo-display', display) # setAttribute handles escaping
        textBox.style.position = "absolute"
        textBox.style.fontSize = "8pt"
        textBox.style.border = "2px solid black"
        textBox.style.textAlign = "center"
        @setDimensions(textBox, left + 2, top + 2, right - 2, bottom - 2)
        textBox.innerHTML = display
        session.container.appendChild(textBox)
    )
    #alert("Output")
  addOutput: (display, left, top, right, bottom) ->
    #alert("Output")
  addView: (left, top, right, bottom) ->
    @widgets.push((session) =>
      @setDimensions(session.controller.layers, left, top, right, bottom)
    )
  addPlot: (display, left, top, right, bottom, ymin, ymax, xmin, xmax) ->
    @widgets.push((session) =>
      if(session.plot)
        plot = document.createElement('div')
        plot.style.position = "absolute"
        plot.style.border = "1px solid black"
        @setDimensions(plot, left, top, right, bottom)
        session.container.appendChild(plot)
        session.plot.boot(display, ymin, ymax, xmin, xmax, plot)
    )
