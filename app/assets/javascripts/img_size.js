$('img[src*="//cdn.shopify.com/s/files"]').filter('img[src*="products"]').each(function(i) {
	url = $(this).attr('src');
	filename = url.substring(url.indexOf("/products/")+10,url.indexOf("?v"));
	size_ref = filename.substring(filename.lastIndexOf("_")+1, filename.lastIndexOf("."));
	//regex: (large|grande|[0-9]+x[0-9]+|[0-9]+x)
	var patt = new RegExp("(large|grande|[0-9]+x[0-9]+|[0-9]+x)");
	var res = patt.test(size_ref);

	//if matches regex pattern, replace with 1024x
	if (res) {
		new_filename = filename.replace(size_ref, "1024x");
		new_url = url.replace(filename, new_filename);
		$(this).attr('src') = new_url;
	}
	//console.log("src: " + $(this).attr('src'));

});

//cases

//a17bc0cbec49741933b6bfd54e4b593f_grande.png
//a17bc0cbec49741933b6bfd54e4b593f.png

//SG27_front_81aaf036-6609-4b8e-a0dc-6dfe15b1997f_large.png
//SG27_front_81aaf036-6609-4b8e-a0dc-6dfe15b1997f.png