<html>
<head>
	<title>Stock Prices</title>
	<style type="text/css">
	<#--Mayank Search Bar-->
	.left {
    float:left;
}
.rounded {
    -webkit-border-radius:5px;
    -moz-border-radius:5px;
    border-radius:5px;
}
.wrap {
    position:relative;
    padding:5px 6px 6px 7px; /* readjust in jsfiddle*/
    background:#f0f0f0;
    border:1px solid #ccc;
    overflow:hidden;
}
.search {
    width:360px;
    position:relative; top:2px; /* readujst in jsfiddle */
    padding:8px 5px 8px 30px;
    border:1px solid #ccc;
    background:white url(http://i.imgur.com/lFkqn.png) left center no-repeat;
}
.go {
    position:relative; top:0;
    padding:3px 5px 2px;
    margin-left:8px;
    border:none;
    background: -webkit-gradient(linear, left top, left bottom, from(#d631a7), to(#8f1b64));
    background: -moz-linear-gradient(top,  #d631a7,  #8f1b64);
}
.go span {
    display:block;
    width:64px; height:28px;
    background:url('/public/images/search.png') 0 0 no-repeat;
}
<#-- serach bar css ends here -->
		.container
		{
			background: #ECECEC none;
			border: 1px solid #D5D4D4;
			height: 30px;
			margin: 0 auto;
			width: 928px;
		}
		.container .wrap
		{
			width: 920px;
			left: 5px;
			top: 0px;
			overflow: hidden;
			position: relative;
			line-height: 30px;
			font-size-adjust: none;
		}
		div.stockTicker
		{
			font-size: 18px;
			list-style-type: none;
			margin: 0;
			padding: 0;
			position: relative;
		}
		div.stockTicker span.quote
		{
			margin: 0;
			font-weight: bold;
			color: #000;
			padding: 0 5px 0 10px;
		}
		.GreenText
		{
			color: Green;
		}
		.RedText
		{
			color: Red;
		}
		.up_green
		{
			background: url(http://www.codescratcher.com/wp-content/uploads/2014/11/up.gif) no-repeat left center;
			padding-left: 10px;
			margin-right: 5px;
		}
		.down_red
		{
			background: url(http://www.codescratcher.com/wp-content/uploads/2014/11/down.gif) no-repeat left center;
			padding-left: 10px;
			margin-right: 5px;
		}
	</style>
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
    <script type="text/javascript">
		(function($) {
			$.fn.jStockTicker = function(options) {
				if (typeof (options) == 'undefined') {
					options = {};
				}
				var settings = $.extend( {}, $.fn.jStockTicker.defaults, options);
				var $ticker = $(this);
				var $wrap = null;
				settings.tickerID = $ticker[0].id;
				$.fn.jStockTicker.settings[settings.tickerID] = {};

				if ($ticker.parent().get(0).className != 'wrap') {
					$wrap = $ticker.wrap("<div class='wrap'></div>");
				}

				var $tickerContainer = null;
				if ($ticker.parent().parent().get(0).className != 'container') {
					$tickerContainer = $ticker.parent().wrap(
							"<div class='container'></div>");
				}

				var node = $ticker[0].firstChild;
				var next;
				while(node) {
					next = node.nextSibling;
					if(node.nodeType == 3) {
						$ticker[0].removeChild(node);
					}
					node = next;
				}

				var shiftLeftAt = $ticker.children().get(0).offsetWidth;
				$.fn.jStockTicker.settings[settings.tickerID].shiftLeftAt = shiftLeftAt;
				$.fn.jStockTicker.settings[settings.tickerID].left = 0;
				$.fn.jStockTicker.settings[settings.tickerID].runid = null;
				$ticker.width(2 * screen.availWidth);

				function startTicker() {
					stopTicker();

					var params = $.fn.jStockTicker.settings[settings.tickerID];
					params.left -= settings.speed;
					if(params.left <= params.shiftLeftAt * -1) {
						params.left = 0;
						$ticker.append($ticker.children().get(0));
						params.shiftLeftAt = $ticker.children().get(0).offsetWidth;
					}

					$ticker.css('left', params.left + 'px');
					params.runId = setTimeout(arguments.callee, settings.interval);

					$.fn.jStockTicker.settings[settings.tickerID] = params;
				}

				function stopTicker() {
					var params = $.fn.jStockTicker.settings[settings.tickerID];
					if (params.runId)
						clearTimeout(params.runId);

					params.runId = null;
					$.fn.jStockTicker.settings[settings.tickerID] = params;
				}

				function updateTicker() {
					stopTicker();
					startTicker();
				}

				$ticker.hover(stopTicker,startTicker);
				startTicker();
			};

			$.fn.jStockTicker.settings = {};
			$.fn.jStockTicker.defaults = {
				tickerID :null,
				url :null,
				speed :1,
				interval :20
			};
		})(jQuery);
    </script>
	<script type="text/javascript">
		$(window).load(function () {
            StockPriceTicker();
            setInterval(function() {StockPriceTicker();} , 60000);
        });
        function StockPriceTicker() {
            var Symbol = "", CompName = "", Price = "", ChnageInPrice = "", PercentChnageInPrice = "";
            var CNames = "^FTSE,HSBA.L,SL.L,BATS.L,BLND.L,FLG.L,RBS.L,RMG.L,VOD.L";
            var flickerAPI = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22" + CNames + "%22)&env=store://datatables.org/alltableswithkeys";
            var StockTickerHTML = "";

            var StockTickerXML = $.get(flickerAPI, function(xml) {
                $(xml).find("quote").each(function () {
                    Symbol = $(this).attr("symbol");
                    $(this).find("Name").each(function () {
                        CompName = $(this).text();
                    });
                    $(this).find("LastTradePriceOnly").each(function () {
                        Price = $(this).text();
                    });
                    $(this).find("Change").each(function () {
                        ChnageInPrice = $(this).text();
                    });
                    $(this).find("PercentChange").each(function () {
                        PercentChnageInPrice = $(this).text();
                    });

                    var PriceClass = "GreenText", PriceIcon="up_green";
                    if(parseFloat(ChnageInPrice) < 0) { PriceClass = "RedText"; PriceIcon="down_red"; }
                    StockTickerHTML = StockTickerHTML + "<span class='" + PriceClass + "'>";
                    StockTickerHTML = StockTickerHTML + "<span class='quote'>" + CompName + " (" + Symbol + ")</span> ";

                    StockTickerHTML = StockTickerHTML + parseFloat(Price).toFixed(2) + " ";
                    StockTickerHTML = StockTickerHTML + "<span class='" + PriceIcon + "'></span>" + parseFloat(Math.abs(ChnageInPrice)).toFixed(2) + " (";
                    StockTickerHTML = StockTickerHTML + parseFloat( Math.abs(PercentChnageInPrice.split('%')[0])).toFixed(2) + "%)</span>";
                });

                $("#dvStockTicker").html(StockTickerHTML);
                $("#dvStockTicker").jStockTicker({interval: 30, speed: 2});
            });
        }
    $(document).ready(function(){  
    		

$(".search").keyup(function(event){
    if(event.keyCode == 13){
        $(".go").click();
    }
});

    $("button").click(function(e){
    	var searchInput = $(".search").val();
    	if(searchInput.length!=0)
    	{
    		$( "#alert" ).hide();
    	window.location.href = '/?symbol='+searchInput;	
    	}
    	else
    	{
$( "#alert" ).show();
        }
        });
});



    </script>
</head>
<body>

    <div id="StockTickerContainer" style="height: 32px; line-height: 32px; overflow: hidden;">
        <div id='dvStockTicker' class='stockTicker'>
        </div>
    </div>
    <table style="margin-left: 30%; margin-top: 10px;">
    <tr>
    <td>
    <div class="wrap left rounded">
    <table>
    <tr><td><input type="text" class="search left rounded" value=<#if symbol??>${symbol}<#else>""</#if> /></td>
    <td><button class="go left rounded"><span></span></button></td>
    <tr>
    <td id ="alert" style="display:none;">
    	<p style ="font-weight: bold;">Please provide input in Search bar !</p>
    </td>	
    </tr>
    </table>
</div>
</td>
</tr>
<tr><td style="margin-top: 10px;">
<#if stock??>
    <div id="StockDisplayer">
    <table>
    <tr><td>Symbol:</td><td>${stock.symbol}</td></tr>
    <tr><td>Name:</td><td>${stock.name}</td></tr>
    <tr><td>Currency:</td><td>${stock.currency}</td></tr>
    <tr><td>Stock Exchange:</td><td>${stock.stockExchange}</td></tr>
    <tr><td>Price:</td><td>${stock.price}</td></tr>
    <tr><td>Change:</td><td>${stock.priceDiff}(${stock.priceDiffPercentage}%)</td></tr>
    </table>
    </td></tr>
    </table>
    </div>
    </#if>
</body>
</html>