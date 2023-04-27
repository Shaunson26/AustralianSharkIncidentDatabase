// Set up vis height and positioning
function visSizer() {
    //let windowHeight = window.innerHeight
    let visDiv = document.querySelector('#vis')
    //visDiv.style.height = `${windowHeight}px`;
    visDiv.style.maxWidth = `${window.outerWidth}px`
}

function visPosition() {
    let visDiv = document.querySelector('#vis')
    let visDivInitialTop = visDiv.getBoundingClientRect().top
    let endDiv = document.querySelector('#end')
    let endDivInitialTop = endDiv.getBoundingClientRect().top
   /* let hr = document.createElement('hr')
    hr.style.position = 'absolute'
    hr.style.top = `${endDivInitialTop}px`
    hr.style.margin = 0
    hr.style.border = '2px solid red'
    hr.style.width = '100%'
    document.querySelector('body').append(hr)*/
    return {
        top: visDivInitialTop,
        bottom: endDivInitialTop
    }
}

function vizPositioner(visPosition) {

    let visDiv = document.querySelector('#vis')
    let visDivPosition = getComputedStyle(visDiv).position
    let scrollTopLocation = document.documentElement.scrollTop
    let scrollBottomLocation = document.documentElement.scrollTop + visDiv.getBoundingClientRect().height

    if (scrollTopLocation < visPosition.top) {
        if (visDivPosition == 'fixed') {
            //console.log('visDiv absolute top')
            visDiv.style.position = 'absolute'
            visDiv.style.top = 'unset';
        }
    }

    if (scrollTopLocation > visPosition.top & scrollBottomLocation < visPosition.bottom) {
        if (visDivPosition == 'absolute') {
            //console.log('visDiv fixed')
            visDiv.style.position = 'fixed'
            visDiv.style.top = 0;
            visDiv.style.bottom = 'unset';
        }
    }

    if (scrollTopLocation > visPosition.top & scrollBottomLocation > visPosition.bottom) {
        if (visDivPosition == 'fixed') {
            // console.log('hit bottom')
            visDiv.style.position = 'absolute'
            visDiv.style.top = 'unset';
            visDiv.style.bottom = 0;
        }
    }

}

//
function buildThresholdList() {
    let thresholds = [];
    let numSteps = 20;

    for (let i = 1.0; i <= numSteps; i++) {
        let ratio = i / numSteps;
        thresholds.push(ratio);
    }

    thresholds.push(0);
    return thresholds;
}

function scroller() {
    let currentVis = 'box1';

    // visualisation intersections
    let options = {
        // Defaults to the browser viewport if not specified or if null.
        //root: document.querySelector("body"),
        rootMargin: "0px",
        // When should the callback be fired
        threshold: buildThresholdList()
    };

    let callback = (entries, observer) => {
        entries.forEach((entry) => {
            //console.log(entry)
            //if (entry.isIntersecting) {
            //   console.log(entry.target.id, 'intersectionRatio:', Math.floor(entry.intersectionRatio * 100))
            //}

            if (entry.intersectionRatio > 0.5 & currentVis !== entry.target.id) {
                console.log(entry.target.id)
                currentVis = entry.target.id
                updateVisualisation(currentVis.substring(4))
            }
            // Each entry describes an intersection change for one observed
            // target element:
            //   entry.boundingClientRect
            //   entry.intersectionRatio
            //   entry.intersectionRect
            //   entry.isIntersecting
            //   entry.rootBounds
            //   entry.target
            //   entry.time
        });



    };


    let observer = new IntersectionObserver(callback, options);
    let targets = document.querySelectorAll(".step");
    targets.forEach(el => observer.observe(el));

}

function randomXY(n, width, height) {
    let tmp = {
        x: Array.from({ length: n }, d3.randomNormal(width / 2, width / 10)),
        y: Array.from({ length: n }, d3.randomNormal(height / 2, height / 10))
    }

    let xy = tmp.x.map((v, i) => ({ x: v, y: tmp.y[i] }))

    return xy

}

Chart.defaults.backgroundColor = 'white';
Chart.defaults.borderColor = 'rgba(255,255,255,0.25)';
Chart.defaults.color = 'white';
Chart.defaults.plugins.legend.display = false
Chart.defaults.maintainAspectRatio = false

function vertOptions(title) {

    return {
        scales: {
            x: {
                grid: {
                    display: false
                }
            },
            y: {
                title: {
                    display: true,
                    text: title
                },
                border: {
                    display: false
                }
            }
        }
    }
}

function initialiseVisualisation() {

    new Chart('visplot',
        {
            type: 'bar',
            data: {
                labels: data.incidentsByYear['Incident.year'],
                datasets: [
                    {
                        data: data.incidentsByYear.n,
                        backgroundColor: 'rgba(255,255,255,0.80)',
                    }
                ]
            },
            options: vertOptions('Number of incidents')
        }
    )


}

function updateVisualisation(index) {

    let vis = Chart.getChart('visplot')

    if (index == 0) {
        if (vis == null) {
            initialiseVisualisation()
        } else {
            vis.data.labels = data.incidentsByYear['Incident.year']
            vis.data.datasets[0].data = data.incidentsByYear.n
            vis.update()
        }
    }

    if (index == 1) {

        vis.data.labels = data.incidentsBySpecies.data['Shark.common.name']
        vis.data.datasets[0].data = data.incidentsBySpecies.data.n

        vis.update()

    }

    if (index == 2) {

        vis.data.labels = data.incidentsByActivity['Victim.activity']
        vis.data.datasets[0].data = data.incidentsByActivity.n
        vis.update()

    }

    if (index == 3) {

        vis.data.labels = data.incidentsByTime['Time.of.incident']
        vis.data.datasets[0].data = data.incidentsByTime.n,
        vis.update()

    }
}

