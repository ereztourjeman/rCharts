rCharts = setRefClass('rCharts', list(params = 'list', lib = 'character', LIB = 'list',
    srccode = 'ANY', tObj = 'list', container = 'character'), methods = list(
  initialize = function(){
    srccode <<- NULL; tObj <<- list(); LIB <<- list(); container <<- 'div'
    params <<- list(dom = basename(tempfile('chart')),
      width = getOption('RCHART_WIDTH', 800), 
      height = getOption('RCHART_HEIGHT', 400)
    )
  },
  addParams = function(...){
    params <<- modifyList(params, list(...))
  },
  set = function(...){
    if (length(LIB) == 0){
      LIB <<- get_lib(lib)
    }
    params <<- modifyList(params, list(...))
  },
  getPayload = function(chartId){
    list(chartParams = toJSON(params), chartId = chartId, lib = basename(lib))
  },
  html = function(chartId = NULL){
    if (!is.null(chartId)) params$dom <<- chartId else chartId <- params$dom
    params$id <<- params$dom
    template = read_file(file.path(LIB$url, 'layouts', 'chart.html'))
    html = render_template(template, getPayload(chartId))
    return(html)
  },
  # TO DEPRECATE
  printChart = function(chartId = NULL){
    if (!is.null(chartId)) params$dom <<- chartId else chartId <- params$dom
    chartDiv = sprintf("<div id='%s' class='rChart nvd3Plot'></div>", chartId)
    writeLines(c(chartDiv, .self$html(chartId)))
  },
  print = function(chartId = NULL){
    if (!is.null(chartId)) params$dom <<- chartId else chartId <- params$dom
    chartDiv = sprintf("<%s id='%s' class='rChart nvd3Plot %s'></%s>", 
      container, chartId, LIB$name, container)
    writeLines(c(chartDiv, .self$html(chartId)))
  },
  render = function(chartId = NULL, cdn = F){
    if (!is.null(chartId)) params$dom <<- chartId else chartId <- params$dom
    template = read_template(getOption('RCHART_TEMPLATE', 'rChart.html'))
    html = render_template(template, list(
      params = params,
      assets = get_assets(LIB, static = T, cdn = cdn),
      chartId = chartId,
      script = .self$html(chartId),
      CODE = srccode,
      lib = LIB$name,
      tObj = tObj,
      container = container
    ))
  },
  save = function(destfile = 'index.html', ...){
    writeLines(.self$render(...), destfile)
  },
  show = function(static = T, ...){
    if (static){
      tf <- tempfile(fileext = '.html');
      writeLines(.self$render(...), tf)
      browseURL(tf)
      # system(sprintf("open %s", tf))
    } else {
      shiny_copy = .self$copy()
      shiny_copy$params$dom = 'show'
      assign(".rChart_object", shiny_copy, envir = .GlobalEnv)
      shiny::runApp(file.path(system.file(package = "rCharts"), "shiny"))
    }
  },
  publish = function(description = "", ..., host = 'gist'){
    htmlFile = file.path(tempdir(), 'index.html'); on.exit(unlink(htmlFile))
    .self$save(destfile = htmlFile, cdn = T)
    if (!is.null(.self$srccode)){
      codeFile = file.path(tempdir(), 'code.R'); on.exit(unlink(htmlFile))
      writeLines(.self$srccode, con = codeFile)
      files = c(htmlFile, codeFile)
    } else {
      files = htmlFile
    }
    class(files) = host
    publish_(files = files, description = description, ...)
  }
))


