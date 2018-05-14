require "Module"


dataPath = "data/anim.csv";
numRows = 0;
numCols = 0;
colMin = {};
colMax = {};
colNames = {};

plotX1 = 0
plotY1 = 0
plotX2 = 0
plotY2 = 0
diffBetweenXCoords = 0;

titleFont = nil;
labelFont = nil ;
axisLimitsFont = nil;

axisColor       = { "333333", "000000" };
fontAxisColor   = { "333333", "FF2222" };
fontLimitsColor = { "555555", "FF2222" };
triangleColor   = "888888";
linesColor      = { "ED1317", "1397ED" };

axisOrder = {};
axisFlipped = {};

--setup
--André Arroyo 
--Fabian Campos
--Kenneth Fernandez

function setup()
  size(1000, 500);

  --Read data
  --objeto
  data = FloatTable:new()
  data:construc(dataPath);
  numRows = data:getRowCount();
  numCols = data:getColumnCount();
  colNames = data:getColumnNames();


  for col = 1,numCols, 1 do
    local maxNumber = data:getColumnMax(col);
    local minNumber = data:getColumnMin(col);

    colMin[col] = int(floor(minNumber));
    colMax[col] = int(ceil(maxNumber));

    axisOrder[col] = col;
    axisFlipped[col] = false;
  end

  --Fonts
  titleFont = loadFont("data/Vera.ttf", 16);
  labelFont = loadFont("data/Vera.ttf", 11);
  axisLimitsFont = loadFont("data/Vera.ttf", 11);

  --Plot area limits
  plotX1 = 30;
  plotX2 = width() - plotX1;
  plotY1 = 60;
  plotY2 = height() - plotY1;

  diffBetweenXCoords = (plotX2 - plotX1) / (numCols - 1);

  if frame ~= nil then
    frame.setTitle(dataPath);
  end
end

function draw()
    --Background
    background(240);

    --Draw the plot area
    fill(240);
    noStroke();
    rect(plotX1, plotY1, plotX2 - plotX1, plotY2 - plotY1);

    --drawTitle();
    drawAxis();
    drawLines();
end

function drawAxis()
  local xCoordsForAxis = plotX1;
  local yAxisLbl = plotY2 + 40;
  local yMinLbl  = plotY2 + 15;
  local yMaxLbl  = plotY1 - 7;
  local yTriMin  = plotY1 - 25;
  local yTriMax  = plotY1 - 35;

  strokeCap(PROJECT); --????
  strokeWeight(1);
  stroke(0);

  for col = 1, numCols do
    colToDraw = axisOrder[col];

    --Draw Axis
    stroke(axisColor[1]);
    line(xCoordsForAxis, plotY1, xCoordsForAxis, plotY2);

    --Label min/max
    textAlign(CENTER);
    textFont(axisLimitsFont);
    fill(fontLimitsColor[1]);
    if axisFlipped[colToDraw] then -- No estoy seguro si este if funcionará así....
      text(colMin[colToDraw], xCoordsForAxis, yMaxLbl);
      text(colMax[colToDraw], xCoordsForAxis, yMinLbl);
    else
      text(colMin[colToDraw], xCoordsForAxis, yMinLbl);
      text(colMax[colToDraw], xCoordsForAxis, yMaxLbl);
    end

    --Axis label
    textFont(labelFont);
    fill(fontAxisColor[1]);
    text(colNames[colToDraw], xCoordsForAxis, yAxisLbl);

    --Triangle
    fill(triangleColor);
    noStroke();
    if(axisFlipped[colToDraw]) then -- No estoy seguro si este if funcionará así....
      triangle(xCoordsForAxis - 3, yTriMax, xCoordsForAxis, yTriMin, xCoordsForAxis + 3, yTriMax);
    else
      triangle(xCoordsForAxis - 3, yTriMin, xCoordsForAxis, yTriMax, xCoordsForAxis + 3, yTriMin);
    end
	xCoordsForAxis = xCoordsForAxis + diffBetweenXCoords
  end
end

function drawLines()
  noFill();
  strokeWeight(1);
  for row = 1, numRows do
    beginShape();
    for column = 1, numCols do
      colToDraw = axisOrder[column];
      if(data.isValid(row, column)) then
		if(axisFlipped[colToDraw]) then
			cMax = colMin[colToDraw]
			cMin = colMax[colToDraw]
		else
			cMax = colMax[colToDraw]
			cMin =colMin[colToDraw]
		end
        value = data.getFloat(row, colToDraw); -- No sé que putas es esto....

        x = plotX1 + diffBetweenXCoords * colToDraw;
        y = map(value, cMin, cMax, plotY2, plotY1);

        --stroke(#5679C1);
        if(colToDraw == 0) then
          stroke(lerpColor(linesColor[1], linesColor[2],  map(value, cMin, cMax, 0., 1.) ), 150 ); -- ????
        end
        vertex(x, y);
      end
    end
    endShape();
  end
end

