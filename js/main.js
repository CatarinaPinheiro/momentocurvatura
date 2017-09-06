var scatterChart;

function fillSteelForms(size){
	$("#steelForms")
		.html("");

	$("<label>")
		.text("Posição de armadura")
		.attr("class","col-sm-6")
		.appendTo("#steelForms");

	$("<label>")
		.text("Área de elemento de aço")
		.attr("class","col-sm-6")
		.appendTo("#steelForms");

	for(var t=0;t<size;t++){

		$("<input>")
			.attr("name","posicao_armadura[]")
			.attr("class","col-sm-6 form-control")
			.attr("placeholder","d")
			.appendTo("#steelForms");

		$("<input>")
			.attr("name","elem_area_aco[]")
			.attr("placeholder","As")
			.attr("class","col-sm-6 form-control")
			.appendTo("#steelForms");
	}
}

function computeClick(event){
	$(event.target).attr("disabled",true);
	$.post({
		url: "/api",
		data: JSON.stringify($("form").serializeObject()),
		dataType : "json",
		contentType: "application/json; charset=utf-8",
		success: function(data){
			if(typeof(data==="string"))
				data = data;
			var points = [];
			for (var idx in data[0]){
				points.push({
					x: data[0][idx],
					y: data[1][idx]
				})
			}
			scatterChart.data.datasets[0].data = points;
			scatterChart.update();
			$(event.target).attr("disabled",false);
		},
		error: function(){
			$(event.target).attr("disabled",false)
		}
	});
}

$(function(){
	fillSteelForms(0);
	var ctx = $("#plot")[0].getContext('2d');
	scatterChart = new Chart(ctx, {
		type: 'scatter',
		data: {
			datasets: [{
				label: 'Valor Calculado',
				data: []
			}]
		},
		options: {
		}
	});
	$("#computeButton").click(computeClick);
});
