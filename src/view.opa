module View {

  function template(content) {
    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="brand" href="/main">Cactus DB</a>
          <span class="form-search pull-right">
            <input id=#searchtext type="text" class="input-medium search-query" />
            <input type="button" class="btn btn-info" value="locate" onclick={function(_) {findPlant()}} />
          </>
          <div class="nav-collapse collapse">
            <ul class="nav">
              <li><a href="/main">Main</a></li>
              <li><a href="/aging">Aging Report</a></li>
              <li><a href="/meta">Meta</a></li>
            </ul>
          </>
        </>
      </>
    </>
    <div id=#main class="container-fluid">
      <div class="row-fluid">     
        {content} 
      </div>
      <hr>
      <footer>
        <p>Cactus DB</p>
      </footer>
    </div>
  }

  function page(path) {
    /*type reqKind = {root} or {}
    match(path) {
      case {path : [] ...} : 
    }*/
    content = 
      <div class="">
        Eggs brah <br />
        {path}
      </>
    template(content)
  }
  function meta(path) {
    content = 
      <div>
      Meta: {path}
      </>
    template(content)
  }
  function aging(path) {

    content = 
      <div>
      Aging: {path}
      </>
    template(content)
  }
  function find(path) {

    content = 
      <div>
      Find: {path}
      </>
    template(content)
  }
  function plant(path) {
    content = 
      <div>
      Plant: {path}
      </>
    template(content)
  }


  function findPlant() {
    Dom.clear_value(#searchtext)
    void
  }
}

