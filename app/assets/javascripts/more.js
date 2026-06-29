$(document).on('turbolinks:load', function() {    
    var showChar = 300;
    var ellipsestext = "...";
    var moretext = "[more]";
    var lesstext = "[less]";
     $('.more').each(function() {
        var content = $(this).html();
 
        if(content.length > showChar) {
            var c = start_substr (content, showChar)
            var h = content.substr(c.length, content.length - c.length);
            if (h != "") {
                var html = c + '<span class="moreellipses">' + ellipsestext + '</span><span class="morecontent"><span>' + h + '</span>&nbsp;&nbsp;<a href="" class="morelink">' + moretext + '</a></span>';
                $(this).html(html);
            }
        }
    });
     $(".morelink").click(function(){
        if($(this).hasClass("less")) {
            $(this).removeClass("less");
            $(this).html(moretext);
        } else {
            $(this).addClass("less"); 
            $(this).html(lesstext);
        }
         $(this).parent().prev().toggle();
        $(this).prev().toggle();
        return false;
    });

    function start_substr(string, length) {
        var atag = 0, i=length;
        for(i; i>=0; i--)
        {
           if((string[i] == "<") && (string[i+1] == "a"))
           {
              atag = i-1;
              i = 0;
           }
        }

        i = length;
        if (atag > 0)
        {
           i = atag;
        }

        var newString = string.substring(0,(i+1));
        return newString;
    }
});
