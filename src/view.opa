module View {
  function pageWrapper(title, content) {
    Resource.full_page(
      title,
      content,
      <meta name="viewport" content="width=device-width, initial-scale=1.0 , maximum-scale=1.0"/>
      ,
      web_response {success},
      Resource_private.default_customizers
      );
  }
  function template(content) {
    <div class="navbar">
      <div class="navbar-inner">
        <div class="container">
          <a class="brand span2" href="/main">Cactus DB</a>
          <span class="nav-collapse collapse">
            <span class="form-search pull-right" style="text-align: right">
              <input id=#searchtext type="text" class="input-medium search-query" />
              <input type="button" class="btn btn-info" value="locate" onclick={function(_) {findPlant()}} />
            </>
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

