import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainerTischBuchen extends StatefulWidget {
  @override
  _WebViewContainerTischBuchenState createState() => _WebViewContainerTischBuchenState();
}
class _WebViewContainerTischBuchenState extends State<WebViewContainerTischBuchen> {
  late WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(Uri.parse('https://services.gastronovi.com/restaurants/96013/en/reservation/widget?entry=ordering#1'))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            await applyCustomStyles();
          },
        ),
      );
  }
  Future<void> applyCustomStyles() async {
    await controller.runJavaScript(
      """
      (function() {
        // Appliquer les styles généraux
        var styles = `
          body, button, input, textarea, header {
            font-family: poppins;
            color: #ffffff;
            background-color: #000000; /* Couleur de fond du corps */
          }

          .color_1_bgr { background-color: #212121; }
          .color_2_bgr { background-color: #242424; }
          .color_cnt_bgr { background-color: #000000; }
          .color_main_bgr { background-color: #000000; }

          .color_1_fnt { color: #ffffff; }
          .color_2_fnt { color: #ffffff; }
          .color_cnt_fnt { color: #ffffff; }
          .color_2_lnk { color: #ffffff; }
          .color_cnt_lnk { color: #91306a; }
          .color_cnt_cmt { color: #ffffff; }



        .languageButtonWrapper button,
        .alternatives input[type="radio"] + label {
        color:				#ffffff;
        background-color:	#91306a;
        }

        .languageButtonWrapper button:hover,
        .alternatives input[type="radio"] + label:hover,
        .suggestion.alternatives label:hover,
        .alternatives input[type="radio"]:checked + label {
            color:				#91306a;
            background-color:	#ffffff;
        }
          .button.decrement, .button.increment { color: #ffffff; }
          .languageButtonWrapper button, .alternatives input[type="radio"] + label {
            color: #ffffff;
            background-color: #ffffff;
          }
          .languageButtonWrapper button:hover, .alternatives input[type="radio"] + label:hover,
          .suggestion.alternatives label:hover, .alternatives input[type="radio"]:checked + label {
            color: #91306a;
            background-color: #ffffff;
          }
          .flex-item .pathSelectionBoxWraper {
                background: #91306a;
            }
            .pathSelectionBoxWraper {
            background: #91306a;
          }
          .pathSelectionBoxWraper .pathTitle {
            color: #ffffff;
          }
          #body,
          #box-offers {
              background-color: #000000 !important;
          }
          .buttonIcon .cls-1 {
            stroke: #ffffff;
          }
          #body a {
            color: #ffffff;
          }
          #button_to_widget a {
            background-color: #212121;
          }
          #button_to_widget a:hover {
            background-color: #323232;
          }
          #button_to_widget a:active {
            background-color: #000000;
          }

          .accordionTitle, .accordionTitle .placeholder, .accordion.list dt {
            color: #ffffff;
            border: 1px solid #ffffff;
          }
          .accordion.list .content li.active, .accordion.list .content li.active:hover, .accordion.list .content li.active:active {
            color: #91306a;
            background-color: #ffffff;
          }
          .accordion.buttons .content li span {
            color: #ffffff;
            background-color: #91306a;
          }
          .accordion.buttons .content li span:hover {
            color: #91306a;
            background-color: #ffffff;
          }
          .accordion.buttons .content li span:active {
            color: #91306a;
            background-color: #ffffff;
          }
          .accordion.list .content {
            background: #171717;
            border: 1px solid #ffffff;
          }
          #suggestion .suggestion .times span.disabled {
            color:#91306a;
            
          }
        .accordion.list .content li.active,
    .accordion.list .content li.active:hover,
    .accordion.list .content li.active:active {
        color:				#91306a;
        background-color:	#ffffff;
    }
    .accordion.buttons .content li.active span,
    .accordion.buttons .content li.active span:hover,
    .accordion.buttons .content li.active span:active{
        color:				#91306a;
        background-color:	#ffffff;
        /*-webkit-box-shadow:	inset 0px -3px 0px 0px #000000;
        -moz-box-shadow:	inset 0px -3px 0px 0px #000000;
        box-shadow:			inset 0px -3px 0px 0px #000000;*/
    }

    .accordion.buttons .content li span {
        color:				#ffffff;
        background-color:	#91306a;
    }

    .accordion.buttons .content li span:hover {
        color:				#91306a;
        background-color:	#ffffff;
    }

    .accordion.buttons .content li span:active {
        color:				#91306a;
        background-color:	#ffffff;
        -webkit-box-shadow: none;
        -moz-box-shadow: none;
        box-shadow: none;
        -webkit-transition: none;
        -moz-transition: none;
        transition: none;
    }

    .accordion.list .content {
        background: #171717;
        border: 1px solid #ffffff;
        border-top: none;
    }
          #calendar .dates span:not(.active):not(.disabled):hover:before,
    #suggestion .suggestion .times span:not(.disabled):not(.active):hover,
    .accordion.list .content li:not(.disabled):not(.active):hover {
        background-color:	#91306a;
    }
    #button_to_widget a{background-color: #91306a;}
    #button_to_widget a:hover{background-color: #91306a;}
    #button_to_widget a:active{background-color: #91306a;}
    #calendar .header p,
    .personsheadline {
        color: #91306a;
    }

    #calendar .days {
        color: #ffffff;
    }

    #voucherDownload .downloadlink {
        color: #ffffff;
    }

    /** BUTTONS **/
    #body a.plusbutton {
        color: #ffffff;;
    }


    .button.color,
    .customerForm ul.gender li input[type="radio"]:checked ~ label:before,
    .customerForm ul.gender li input[type="radio"]:hover:checked ~ label:before,
    .customerForm ul.gender li input[type="radio"]:active:checked ~ label:before {
        color:				#ffffff;
        background-color:	#212121;
        /*-webkit-box-shadow:	inset 0px -3px 0px 0px #000000;
        -moz-box-shadow:	inset 0px -3px 0px 0px #000000;
        box-shadow:			inset 0px -3px 0px 0px #000000;*/
    }
    .button.color:hover {
        background-color:	#ffffff;
        /*-webkit-box-shadow:	inset 0px -3px 0px 0px #212121;
        -moz-box-shadow:	inset 0px -3px 0px 0px #212121;
        box-shadow:			inset 0px -3px 0px 0px #212121;*/
    }
    .button.color:active {
        background-color:	#000000;
        /*-webkit-box-shadow:	none;
        -moz-box-shadow:	none;
        box-shadow:			none;*/
    }
    /**
    .button.gray:before {
        color:				#777777;
    }
    .button.gray {
        color:				#777777;
        background-color:	#E9E9E9;
        -webkit-box-shadow:	inset 0px -3px 0px 0px #C0C0C0;
        -moz-box-shadow:	inset 0px -3px 0px 0px #C0C0C0;
        box-shadow:			inset 0px -3px 0px 0px #C0C0C0;
    }
    .button.gray:hover {
        background-color:	#F4F4F5;
        -webkit-box-shadow:	inset 0px -3px 0px 0px #E9E9E9;
        -moz-box-shadow:	inset 0px -3px 0px 0px #E9E9E9;
        box-shadow:			inset 0px -3px 0px 0px #E9E9E9;
    }
    .button.gray:active {
        backgrond-color:	#C0C0C0;
        -webkit-box-shadow:	none;
        -moz-box-shadow:	none;
        box-shadow:			none;
    }
    */

    .button.green:not(.disabled) {
        background-color: #91306a;
        color:            #ffffff;
    }

    .button.disabled,
    .button.disabled:hover,
    .button.disabled:active {
        cursor: default;
        background-color: #91306a;
        color: #ffffff;
        filter: brightness(50%);
    }

    @media (pointer: fine) {
        .button.green:hover {
            color:				#91306a;
            background-color:	#ffffff;
        }
    }
        `;
        var styleSheet = document.createElement("style");
        styleSheet.type = "text/css";
        styleSheet.innerText = styles;
        document.head.appendChild(styleSheet);
      })();
      """
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'tisch buchen',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
    ),
    body: Column(
      children: [
        Expanded(
          flex: 3, 
          child: Center(
            child: Image.asset(
              "assets/logo/bmoovd_wortmarke_subline_wht.png",
              height: 100,
              width: 100,
            ),
          ),
        ),
        Expanded(
          flex: 7, // 70% de la hauteur totale
          child: WebViewWidget(controller: controller),
        ),
      ],
    ),
  );
}

}
