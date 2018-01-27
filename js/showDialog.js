//dialog div

$('body').append('<div id="dialog"></div>');

function showDialog(v_page, v_title, v_height, v_width){

if (v_height == null){

    v_height = "600px";

}

if (v_width == null){

    v_width = "700px";

}

  v_page = '<iframe src="'+v_page+'" frameborder="0" width="100%" height="100%"></iframe>';

  $('#dialog').html(v_page);

  $('#dialog').dialog({

    width: v_width,

    height: v_height,

    title: v_title,

    position: "center",

    modal : true,

    closeOnEscape: true

});

$("#dialog").css("height",v_height);

}

.thin_border {

border: 1px solid rgb(197, 197, 197);

padding: 10px;

border-radius: 3px;

margin-top: 12px;

margin-left: 5px;

}

.thin_border_title {

                font-size: 1.2em;

                color: rgb(77, 76, 76);

                position: relative;

                top: -20px;

                background-color: white;

                width: 50%;

                font-weight: bold;

        padding: 3px;

        border: 1px solid rgb(223, 223, 223);

        border-radius: 2px;

}

Thin Border

<div class="thin_border" id="#REGION_STATIC_ID#" #REGION_ATTRIBUTES#>

<div style="text-align: right;">#CLOSE##PREVIOUS##NEXT##DELETE##EDIT##CHANGE##CREATE##CREATE2##EXPAND##COPY##HELP#</div>

#BODY#

</div>

Thin Border with Title

<div class="thin_border" #REGION_ATTRIBUTES# id="#REGION_STATIC_ID#">

   <div class="thin_border_title">#TITLE#</div>

   <div style="text-align: right;">#CLOSE##PREVIOUS##NEXT##DELETE##EDIT##CHANGE##CREATE##CREATE2##EXPAND##COPY##HELP#</div>

#BODY#

</div>