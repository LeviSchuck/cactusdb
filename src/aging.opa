module Aging {
	function page(path) {
		content = 
		<div>
		  Aging: {path}
		</>
		View.template(content)
	}
}