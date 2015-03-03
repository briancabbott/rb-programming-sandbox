$(document).ready(function() {
    var baseObj = $("#vote-base-url");
    var base = "";

    if(baseObj.length > 0) {
      base = baseObj.val();
    }

    if($(".issue").length && $("#vote").length) {
        var queue = [];

        $('.description > .wiki:first').each(
            function() {
                queue.push($(this));
            }
        );

        $('.description > .wiki:first').after($('<span></span>').css({clear: 'both'}))

        var execQueue = function() {
            if(queue.length) {
                queueStep(queue.shift());
            }
        };

        var queueStep = function(that) {
            var deferred = $.Deferred();
            var vote = $("#vote").clone().show().attr({ id: null });
            that.css({float: 'left', width: '94%'}).before(vote);

            var issue = vote.data("issue");
            var votePoint = vote.find(".vote-point:first");
            var voteCheck = vote.find(".vote-check:first");
            
            $.ajax({
                type: "GET",
                url: base + "issues/" + issue + "/vote",
                cache: false,
                error: function(jqXHR, textStatus, errorThrown) {
                    votePoint.html("-");
                },
                success: function(data, textStatus, jqXHR) {
                    votePoint.html(data.point);
                    voteCheck.html(data.vote ? "☑" : "✅");
                }

            }).always(function() {
                deferred.always();

                vote.find(".vote-button").bind("click", function(event) {
                    event.preventDefault();
                    var point = $(this).data("point");
                    $.ajax({
                        type: "POST",
                        url: base + "issues/" + issue + "/vote",
                        data: { point: point },
                        cache: false,
                        success: function(data, textStatus, jqXHR) {
                            votePoint.html(data.point);
                            voteCheck.html(data.vote ? "☑" : "✅");
                        }
                    });
                });

                execQueue();
            });
            return deferred.promise();
        };
        execQueue();
    };
});
