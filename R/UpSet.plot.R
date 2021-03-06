#' @importFrom grid grid.newpage
#' @importFrom grid pushViewport
#' @importFrom grid viewport
#' @importFrom grid grid.layout
#' @importFrom grid grid.draw
#' @importFrom grid popViewport
#' @importFrom grid legendGrob
#' @importFrom grid gpar

## Assemble plots to make UpSet plot
Make_base_plot <- function(Main_bar_plot, Matrix_plot, Size_plot, labels, hratios, att_x, att_y,
                           Set_data, exp, position, start_col, att_color, QueryData,
                           attribute_plots, legend, query_legend, boxplot, names, set_metadata){
  
  end_col <- ((start_col + as.integer(length(labels))) - 1)
  Set_data <- Set_data[which(rowSums(Set_data[ ,start_col:end_col]) != 0), ]
  Main_bar_plot$widths <- Matrix_plot$widths
  Matrix_plot$heights <- Size_plot$heights
  if(is.null(set_metadata) ==F){
    set_metadata$heights <- Size_plot$heights
  }
  if(is.null(legend)==F){
    legend$widths <- Matrix_plot$widths
  }
  if(is.null(boxplot) == F){
    for(i in seq_along(boxplot)){
      boxplot[[i]]$widths <- Matrix_plot$widths
    }
  }
  
  size_plot_height <- (((hratios[1])+0.01)*100)
  if((hratios[1] > 0.7 || hratios[1] < 0.3) ||
       (hratios[2] > 0.7 || hratios[2] < 0.3)) warning("Plot might be out of range if ratio > 0.7 or < 0.3")
  if(is.null(attribute_plots) == T && is.null(boxplot) == T){
    NoAttBasePlot(legend, size_plot_height, Main_bar_plot, Matrix_plot, hratios, Size_plot, query_legend,
                  set_metadata)
  }
  else if(is.null(attribute_plots) == F && is.null(boxplot) == T){
    plots <- GenerateCustomPlots(attribute_plots, Set_data, QueryData, att_color, att_x, att_y, names)
    #      for(i in seq_along(plots)){
    #        attribute_plots$plots[[i]]$plot <- plots[[i]]
    #      }
    BaseCustomPlot(attribute_plots, plots, position, size_plot_height, Main_bar_plot, Matrix_plot, Size_plot,
                   hratios, legend, query_legend, set_metadata)
  }
  else if(is.null(boxplot)==F && is.null(attribute_plots) == T){
    BaseBoxPlot(boxplot, position, size_plot_height, Main_bar_plot, Matrix_plot, Size_plot,
                hratios, set_metadata)
  }
}

## Viewport function
vplayout <- function(x,y){
  viewport(layout.pos.row = x, layout.pos.col = y)
}

## Generates UpSet plot with boxplots representing distributions of attributes
BaseBoxPlot <- function(box_plot, position, size_plot_height, Main_bar_plot, Matrix_plot,
                        Size_plot, hratios, set_metadata){
  if(length(box_plot) > 2){
    return(warning("UpSet can only show 2 box plots at a time"))
  }
  if(is.null(position) == T || position == tolower("bottom")){
    bar_top <- 1
    matrix_bottom <- 100
    att_top <- 101
    att_bottom <- 130
    if(length(box_plot) == 2){
      att_top <- 105
      att_bottom <- 120
      gridrow <- 145
    }
  }
  if((is.null(position) == F) && (position != tolower("bottom"))){
    if(length(box_plot)==1){
      size_plot_height <- (size_plot_height + 35)
      bar_top <- 36
      matrix_bottom <- 135
      att_top <- 10
      att_bottom <- 35
    }
    else if(length(box_plot) == 2){
      size_plot_height <- (size_plot_height + 50)
      bar_top <- 51
      matrix_bottom <- 150
      att_top <- 15
      att_bottom <- 30
      gridrow <- 150
    }
  }
  if(is.null(set_metadata) == T){
    matrix_and_mainbar_right <- 100
    matrix_and_mainbar_left <- 21
    size_bar_right <- 20
    size_bar_left <- 1
  }
  else if(is.null(set_metadata) == F){
    matrix_and_mainbar_right <- 120
    matrix_and_mainbar_left <- 41
    size_bar_right <- 40
    size_bar_left <- 21
    metadata_right <- 20
    metadata_left <- 1
  }
  grid.newpage()
  if(length(box_plot) == 1){
    pushViewport(viewport(layout = grid.layout(135,matrix_and_mainbar_right)))
  }
  else if(length(box_plot) == 2){
    pushViewport(viewport(layout = grid.layout(gridrow,matrix_and_mainbar_right)))
  }
  vp = vplayout(bar_top:matrix_bottom, matrix_and_mainbar_left:matrix_and_mainbar_right)
  pushViewport(vp)
  grid.draw(arrangeGrob(Main_bar_plot, Matrix_plot, heights = hratios))
  popViewport()
  vp = vplayout(size_plot_height:matrix_bottom, size_bar_left:size_bar_right)
  pushViewport(vp)
  grid.draw(arrangeGrob(Size_plot))
  popViewport()
  if(is.null(set_metadata) == F){
    vp = vplayout(size_plot_height:matrix_bottom, metadata_left:metadata_right)
    pushViewport(vp)
    grid.draw(arrangeGrob(set_metadata))
    popViewport()
  }
  vp = vplayout(att_top:att_bottom, matrix_and_mainbar_left:matrix_and_mainbar_right)
  pushViewport(vp)
  grid.draw(arrangeGrob(box_plot[[1]]))
  popViewport()
  if(length(box_plot) == 2){
    vp = vplayout((att_bottom + 10):(att_bottom + 25), matrix_and_mainbar_left:matrix_and_mainbar_right)
    pushViewport(vp)
    grid.draw(arrangeGrob(box_plot[[2]]))
    popViewport()
  }
}

## Generates UpSet plot when no attributes are selected to be plotted
NoAttBasePlot <- function(legend, size_plot_height, Main_bar_plot, Matrix_plot, hratios,
                          Size_plot, query_legend, set_metadata){
  top <- 1
  bottom <- 100
  if((is.null(legend) == F) && (query_legend != tolower("none"))){
    if(query_legend == tolower("top")){
      top <- 3
      bottom <- 102
      legend_top <- 1
      legend_bottom <- 3
      size_plot_height <-(size_plot_height + 2)
    }
    else if(query_legend == tolower("bottom")){
      legend_top <- 101
      legend_bottom <- 103
    }
  }
  if(is.null(set_metadata) == T){
    matrix_and_mainbar_right <- 100
    matrix_and_mainbar_left <- 21
    size_bar_right <- 20
    size_bar_left <- 1
  }
  else if(is.null(set_metadata) == F){
    matrix_and_mainbar_right <- 120
    matrix_and_mainbar_left <- 41
    size_bar_right <- 40
    size_bar_left <- 21
    metadata_right <- 20
    metadata_left <- 1
  }
  grid.newpage()
  if((is.null(legend) == F) && (query_legend != tolower("none"))){
    if(query_legend == tolower("top")){
      pushViewport(viewport(layout = grid.layout(102, matrix_and_mainbar_right)))
    }
    else if(query_legend == tolower("bottom")){
      pushViewport(viewport(layout = grid.layout(103, matrix_and_mainbar_right)))
    }
  }
  else if((is.null(legend) == T)|| (query_legend == tolower("none"))){
    pushViewport(viewport(layout = grid.layout(100,matrix_and_mainbar_right)))
  }
  vp = vplayout(top:bottom, matrix_and_mainbar_left:matrix_and_mainbar_right)
  pushViewport(vp)
  grid.draw(arrangeGrob(Main_bar_plot, Matrix_plot, heights = hratios))
  popViewport()
  vp = vplayout(size_plot_height:bottom, size_bar_left:size_bar_right)
  pushViewport(vp)
  grid.draw(arrangeGrob(Size_plot))
  popViewport()
  if(is.null(set_metadata) == F){
    vp = vplayout(size_plot_height:bottom, metadata_left:metadata_right)
    pushViewport(vp)
    grid.draw(arrangeGrob(set_metadata))
    popViewport()
  }
  if((is.null(legend) == F) && (query_legend != tolower("none"))){
    vp = vplayout(legend_top:legend_bottom, matrix_and_mainbar_left:matrix_and_mainbar_right)
    pushViewport(vp)
    grid.draw(arrangeGrob(legend))
    popViewport()
  }
}

## Function that plots out the list of plots generated from custom plot input
BaseCustomPlot <- function(attribute_plots, plots, position, size_plot_height, Main_bar_plot, Matrix_plot,
                           Size_plot, hratios, legend, q_legend, set_metadata){
  bar_top <- 1
  matrix_bottom <- 100
  custom_top <- 101
  custom_bottom <- (attribute_plots$gridrows + 100)
  
  if(is.null(set_metadata) == T){
    matrix_and_mainbar_right <- 100
    matrix_and_mainbar_left <- 21
    size_bar_right <- 20
    size_bar_left <- 1
  }
  else if(is.null(set_metadata) == F){
    matrix_and_mainbar_right <- 120
    matrix_and_mainbar_left <- 41
    size_bar_right <- 40
    size_bar_left <- 21
    metadata_right <- 20
    metadata_left <- 1
  }
  
  if((is.null(legend) == F) && (q_legend != tolower("none"))){custom_bottom <- (custom_bottom + 5)}
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(custom_bottom,matrix_and_mainbar_right)))
  vp = vplayout(bar_top:matrix_bottom, matrix_and_mainbar_left:matrix_and_mainbar_right)
  pushViewport(vp)
  grid.draw(arrangeGrob(Main_bar_plot, Matrix_plot, heights = hratios))
  popViewport()
  vp = vplayout(size_plot_height:matrix_bottom, size_bar_left:size_bar_right)
  pushViewport(vp)
  grid.draw(arrangeGrob(Size_plot))
  popViewport()
  if(is.null(set_metadata) == F){
    vp = vplayout(size_plot_height:matrix_bottom, metadata_left:metadata_right)
    pushViewport(vp)
    grid.draw(arrangeGrob(set_metadata))
    popViewport()
  }
  if((is.null(legend) == F) && (q_legend != tolower("none"))){
    vp = vplayout(custom_top:(custom_bottom - 5), 1:matrix_and_mainbar_right)
    pushViewport(vp)
    grid.draw(do.call(arrangeGrob, c(plots, ncol = attribute_plots$ncols)))
    popViewport()
    vp = vplayout((custom_bottom - 4):custom_bottom, 1:matrix_and_mainbar_right)
    pushViewport(vp)
    grid.draw(arrangeGrob(legend))
    popViewport()
  }
  else{
    vp = vplayout(custom_top:custom_bottom, 1:matrix_and_mainbar_right)
    pushViewport(vp)
    grid.draw(do.call(arrangeGrob, c(plots, ncol = attribute_plots$ncols)))
    popViewport()
  }
  #   print(attribute_plots$plot, vp = vplayout(attribute_plots$rows, attribute_plots$cols), newpage = F)
}

# printCustom <- function(attribute_plots){
#   print(attribute_plots$plot, vp = vplayout(attribute_plots$rows, attribute_plots$cols), newpage = F)
# }
