//= require jquery
//= require jquery_ujs
//= require_tree .

function populate_regions(world_field) {
    if($(".region-selection").length) {
        $(".region-selection").html('<option>Choose Region</option>');
        if($(".estate-selection")){
            $(".estate-selection").html('<option>Choose Estate</option>');
        };
        populate_select("/json/world_regions/", world_field, $(".region-selection"));
    }
}

function populate_estates(region_field) {
    if($(".estate-selection").length) {
        $(".estate-selection").html('<option>Choose Estate</option>');
        populate_select("/json/region_estates/", region_field, $(".estate-selection"));
    }
}

function populate_characters(house_field) {
    if($(".character-selection").length) {
        $(".character-selection").html('<option>Choose Character</option>');
        populate_select("/json/house_characters/", house_field, $(".character-selection"));
    };
    if($(".single-female-selection").length) {
        $(".single-female-selection").html('<option>Choose Character</option>');
        populate_select("/json/single_females/", house_field, $(".single-female-selection"));
    };
    if($(".single-male-selection").length) {
        $(".single-male-selection").html('<option>Choose Character</option>');
        populate_select("/json/single_males/", house_field, $(".single-male-selection"));
    };
}

function populate_units(army_field) {
    if($(".unit-selection").length) {
        $(".unit-selection").html('<option>Choose Unit</option>');
        populate_select("/json/army_units/",army_field, $(".unit-selection"));
    }
}

function populate_select(url, value_field, selectors) {
    id = $(value_field).val();
    $("#spinner").show();
    $.getJSON(url + id, function(result) {
        $.each(result, function(k,v) {
            $.each(selectors, function(i, s) {
                selectors.append("<option value=\"" + v.value + "\">" + v.display + "</option>");
            });
        });
        $("#spinner").hide();
    });
    
}

function submit_order() {
    if($("#character_id").val() != '' && $("#code").val() != ''){
        $("form#order_form").submit();    
    };
}

function show_item_data_link(help_span,value) {
    link = $(help_span + ' a');
    if(value != '') {
        link.attr('href','/items/' + value + '?static=true');
        link.html('[Databank]');    
    }else {
        link.attr('href','');
        link.html('');    
    };
}

function show_building_data_link(help_span,value) {
    link = $(help_span + ' a');
    if(value != '') {
        link.attr('href','/building_types/' + value + '?static=true');
        link.html('[Databank]');    
    }else {
        link.attr('href','');
        link.html('');    
    };
}