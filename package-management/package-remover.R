library("tools")

remove<- function(pkg, recursive = FALSE){
  d<- package_dependencies(,installed.packages(), recursive = recursive)
  depends<- if(!is.null(d[[pkg]])) d[[pkg]] else character()
  required<- unique(unlist(d[!names(d) %in% c(pkg,depends)]))
  toRemove<- depends[!depends %in% required]
  if(length(toRemove)){
    toRmove <- select.list(c(pkg,sort(toRemove)), multiple = TRUE,
                           title = "Select packages to remove")
    remove.packages(toRmove)
    return(toRmove)
  } else {
    invisible(character())
  }
}

#remove("agricolae")