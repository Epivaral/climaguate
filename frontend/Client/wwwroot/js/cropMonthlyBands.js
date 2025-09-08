// Renders a small 12-month band chart highlighting planting and harvest months plus current month dot with avg score.
(function(){
  const MONTH_MAP = {ENE:1,FEB:2,MAR:3,ABR:4,MAY:5,JUN:6,JUL:7,AGO:8,SEP:9,OCT:10,NOV:11,DIC:12};
  function parseNumericMonths(raw){
    if(!raw) return [];
    const cleaned = raw.replace(/\[|\]|"/g,'');
    return cleaned.split(/[,;\s]+/).map(x=>x.trim()).filter(x=>/^\d{1,2}$/.test(x)).map(Number).filter(m=>m>=1&&m<=12);
  }
  function parseSpanishMonths(raw){
    if(!raw || !/[a-zA-Z]/.test(raw)) return [];
    // Examples: "May-Jun", "Sep-Oct", "May-Jun · Sep-Oct", "May-Jun Sep-Oct"
    const tokens = raw.replace(/\./g,'').replace(/·/g,' ').split(/[,;\s]+/).filter(Boolean);
    const months = new Set();
    for(const t of tokens){
      if(!t) continue;
      const upper = t.toUpperCase();
      if(upper.includes('-')){
        const [a,b] = upper.split('-');
        const start = MONTH_MAP[a];
        const end = MONTH_MAP[b];
        if(start && end){
          if(start<=end){ for(let m=start;m<=end;m++) months.add(m); }
          else { // wrap year just in case (not common here)
            for(let m=start;m<=12;m++) months.add(m); for(let m=1;m<=end;m++) months.add(m);
          }
        }
      } else {
        const single = MONTH_MAP[upper]; if(single) months.add(single);
      }
    }
    return Array.from(months.values()).sort((a,b)=>a-b);
  }
  function parseMonths(raw){
    const nums = parseNumericMonths(raw);
    if(nums.length) return nums;
    return parseSpanishMonths(raw);
  }
  window.renderCropBands = function(canvasId, plantingRaw, harvestRaw, avgScore){
    const cv = document.getElementById(canvasId);
    if(!cv) return;
    const ctx = cv.getContext('2d');
      // Register zone bands plugin once
      if(!window.__zoneBandsRegistered){
        const zoneBandsPlugin = {
          id:'zoneBands',
          beforeDraw(chart, args, opts){
            const zones = (opts && opts.zones) || [];
            const {ctx, chartArea, scales} = chart;
            if(!scales || !scales.y) return;
            const yScale = scales.y; const {left,right,top,bottom} = chartArea;
            zones.forEach(z=>{
              const yTop = yScale.getPixelForValue(z.max);
              const yBottom = yScale.getPixelForValue(z.min);
              ctx.save();
              ctx.fillStyle = z.color;
              ctx.fillRect(left, yTop, right-left, yBottom - yTop);
              ctx.restore();
            });
          }
        };
        if(window.Chart) { window.Chart.register(zoneBandsPlugin); window.__zoneBandsRegistered=true; }
      }
    const planting = parseMonths(plantingRaw);
    const harvest = parseMonths(harvestRaw);
    const labels = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    const currentMonth = new Date().getMonth()+1;
  // Heights for planting / harvest bars (visual lane) full height used
  const plantingData = labels.map((_,i)=> planting.includes(i+1) ? 100 : 0);
  const harvestData = labels.map((_,i)=> harvest.includes(i+1) ? 100 : 0);
    const avg = (typeof avgScore === 'number' && !isNaN(avgScore)) ? Math.max(0, Math.min(100, avgScore)) : null;
    // Determine semaphore color for average
    function avgColor(v){
      if(v==null) return '#6c757d';
      if(v>=85) return '#198754'; // excellent
      if(v>=70) return '#0d6efd'; // good
      if(v>=55) return '#ffc107'; // normal
      return '#dc3545'; // poor
    }
    const avgClr = avgColor(avg);
  // Prevent duplicate rebuilds with same signature
  const signature = JSON.stringify({planting,harvest,avg});
    if(cv._signature === signature && cv.chartInstance){ return; }
    if(cv.chartInstance){ cv.chartInstance.destroy(); }
    cv._signature = signature;
  if(!cv.getAttribute('height')) cv.setAttribute('height', cv.height || 300);
  if(!cv.getAttribute('width')) cv.setAttribute('width', cv.width || 400);
    cv.chartInstance = new Chart(ctx, {
      type:'bar',
      data:{
        labels,
        datasets:[
          {label:'Plantación', data:plantingData, backgroundColor:'rgba(25,135,84,0.22)', borderWidth:0, order:5, barPercentage:0.95, categoryPercentage:0.95},
          {label:'Cosecha', data:harvestData, backgroundColor:'rgba(13,110,253,0.20)', borderWidth:0, order:5, barPercentage:0.95, categoryPercentage:0.95},
          // Threshold lines
          {label:'85%', type:'line', data: labels.map(()=>85), borderColor:'rgba(25,135,84,0.5)', borderWidth:1, pointRadius:0, order:3},
          {label:'70%', type:'line', data: labels.map(()=>70), borderColor:'rgba(13,110,253,0.5)', borderWidth:1, pointRadius:0, order:3},
            {label:'50%', type:'line', data: labels.map(()=>50), borderColor:'rgba(255,193,7,0.5)', borderWidth:1, pointRadius:0, order:3},
            {label:'30%', type:'line', data: labels.map(()=>30), borderColor:'rgba(220,53,69,0.5)', borderWidth:1, pointRadius:0, order:3},
          {label:'Promedio (línea)', type:'line', data: avg!==null ? labels.map(()=>avg) : [], borderColor:avgClr, borderWidth:1, borderDash:[5,4], pointRadius:0, order:2},
          {label:'Promedio Mes Actual', type:'scatter', data: avg!==null ? [{x: labels[currentMonth-1], y: avg}] : [], pointBackgroundColor:avgClr, pointBorderColor:avgClr, pointRadius:6, pointHoverRadius:7, order:1}
        ]
      },
      options:{
  responsive:false,
        animation:false,
        plugins:{
          legend:{display:false},
          tooltip:{enabled:true, callbacks:{
            title:(items)=> items[0]?.label ?? '',
            label:(ctx)=>{
              if(ctx.dataset.type==='scatter') return 'Promedio mes actual: '+ ctx.parsed.y.toFixed(0)+'%';
              if(ctx.dataset.label==='Plantación') return 'Mes de siembra';
              if(ctx.dataset.label==='Cosecha') return 'Mes de cosecha';
              return '';
            }
          }},
          title:{display:true, text:'Calendario & Adecuación', font:{size:11}, padding:{bottom:0}}
        },
        scales:{
          x:{ticks:{font:{size:10}}, grid:{display:true, color:'rgba(0,0,0,0.08)'}, title:{display:true,text:'Mes',font:{size:10}}},
          y:{beginAtZero:true, max:100, ticks:{stepSize:20, font:{size:9}, callback:(v)=> v+''}, grid:{display:true,color:'rgba(0,0,0,0.08)'}, title:{display:true,text:'Puntaje %',font:{size:10}}}
        },
  maintainAspectRatio:false,
        layout:{padding:{top:4,bottom:4,left:4,right:4}}
      }
    });
  };
})();
