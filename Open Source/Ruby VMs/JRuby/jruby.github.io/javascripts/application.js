var trackDownloads = function(){
  $('.trackDownloads a').click(function(){
    var filename = this.pathname.substr(this.pathname.lastIndexOf("/")+1,this.pathname.length);
    _gaq.push(['_trackEvent', 'download', filename]);
    return true;
  });
}

$(document).ready(function(){
  if (document.getElementById('carousel')) {$("div#carousel").codaSlider();};
  trackDownloads();
});