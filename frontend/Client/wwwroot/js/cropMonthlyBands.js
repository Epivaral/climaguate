// Renders a small 12-month band chart highlighting planting and harvest months plus current month dot with avg score.
(function(){
  function parseMonths(raw){
    if(!raw) return [];
    const cleaned = raw.replace(/\[|\]|"/g,'');
    return cleaned.split(/[,;\s]+/).map(x=>x.trim()).filter(x=>/^\d+$/.test(x)).map(Number).filter(m=>m>=1&&m<=12);
  }
  window.renderCropBands = function(canvasId, plantingRaw, harvestRaw, avgScore){
    const cv = document.getElementById(canvasId);
    if(!cv) return;
    const ctx = cv.getContext('2d');
    const planting = parseMonths(plantingRaw);
    const harvest = parseMonths(harvestRaw);
    const labels = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    const currentMonth = new Date().getMonth()+1;
    // Heights for background highlight (percent of axis) so they don't obscure point
  const plantingHeight = 60; // Reduced height so scatter point sits above
  const harvestHeight = 40;  // Staggered height for visual separation
    const plantingData = labels.map((_,i)=> planting.includes(i+1) ? plantingHeight : 0);
    const harvestData = labels.map((_,i)=> harvest.includes(i+1) ? harvestHeight : 0);
    const avg = (typeof avgScore === 'number' && !isNaN(avgScore)) ? Math.max(0, Math.min(100, avgScore)) : null;
    if(cv.chartInstance) cv.chartInstance.destroy();
    cv.chartInstance = new Chart(ctx, {
      type:'bar',
      data:{
        labels,
        datasets:[
          {label:'Plantación', data:plantingData, backgroundColor:'rgba(25,135,84,0.35)', borderWidth:0, order:3, barPercentage:0.9, categoryPercentage:0.9},
          {label:'Cosecha', data:harvestData, backgroundColor:'rgba(13,110,253,0.30)', borderWidth:0, order:3, barPercentage:0.9, categoryPercentage:0.9},
          {label:'Promedio Mes Actual', type:'scatter', data: avg!==null ? [{x: labels[currentMonth-1], y: avg}] : [], pointBackgroundColor:'#dc3545', pointBorderColor:'#66121a', pointRadius:6, pointHoverRadius:7, order:1}
        ]
      },
      options:{
        responsive:true,
        animation:false,
        plugins:{
          legend:{display:false},
          tooltip:{enabled:true, callbacks:{
            title:(items)=> items[0]?.label ?? '',
            label:(ctx)=>{
              if(ctx.dataset.type==='scatter') return 'Promedio: '+ ctx.parsed.y.toFixed(0)+'%';
              if(ctx.dataset.label==='Plantación') return 'Mes de siembra';
              if(ctx.dataset.label==='Cosecha') return 'Mes de cosecha';
              return '';
            }
          }}
        },
        scales:{
          x:{ticks:{font:{size:9}}},
          y:{display:false, beginAtZero:true, max:100}
        },
        maintainAspectRatio:false,
        layout:{padding:{top:2,bottom:2,left:2,right:2}}
      }
    });
  };
})();
