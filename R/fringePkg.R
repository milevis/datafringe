#' @export
list_fringe <- function(path, groups = NULL){
  fidxpath <- file.path(path,"fringe_idx.csv")
  fidx <- read_csv(fidxpath)
  dbs <- fidx  %>% filter(!is.na(id))
  groups <- groups %||% unique(dbs$group)
  if(!is.null(groups)){
    dbs <- dbs %>% filter(group %in% groups)
  }
  fs <- list.files(path,recursive = TRUE)
  dbFiles <- dbs %>% select(id,withDic) %>%
    mutate(data = paste0(id,"_data.csv"), dic = paste0(id,"_dic_.csv"))
  dbFilesWithDic <- dbFiles %>% filter(withDic) %>%
    select(data,dic) %>% flatten_chr
  if(!all(dbFilesWithDic %in% fs))
    stop("db: data and dic not in folder :",
         paste(dbFilesWithDic[!dbFilesWithDic %in% fs],collapse="\n"))
  #dbs %>% separate(id,c("type","name"),extra = "merge")
  dbs
}

#' @export
load_fringes <- function(path, groups = NULL, n_max = Inf){
  frs <- list_fringe(path)
  groups <- groups %||% unique(frs$group)
  frs <- list_fringe(path, groups = groups)
  paths <- file.path(path,frs$id)
  names(paths) <- frs$id
  #f <- readFringe(paths[5],name="hola")
  fpkg <- map2(paths,frs$withDic, ~ readFringe(.x, forceDic = .y,verbose = TRUE, n_max = n_max))
  fpkg
}

#' @export
write_fpkg_sqlite <- function(fringes_path, sqlite_path, fringe_idx = NULL){
  frs <- load_fringes(fringes_path)
  db <- src_sqlite(sqlite_path, create = T)
  # fr <- fpkg[[1]]
  # db_drop_table(db$con,table='objetivos_comparada_data')
  copyFringeToSQlite <- function(fr){
    name <- gsub("-","_",fr$name)
    message("copying: ",name)
    copy_to(db,fr$data, name = paste0(name,"_data"), temporary=FALSE)
    copy_to(db,fr$dic_$d, name = paste0(name,"_dic_"), temporary=FALSE)
    NULL
  }
  map(frs, copyFringeToSQlite)
  if(!is.null(fringe_idx)){
    fridx <- read_csv(fringe_idx)
    copy_to(db,fridx, name = "fringe_idx", temporary=FALSE)
  }
  sqlite_path
}


