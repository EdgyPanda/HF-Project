%QUICK GUIDE:
%
%
%
%1. Specify the directory of the .mat files for the trade quotes only in the 
%myFolder variable below. Currently the script does not support quote data. 
%
%2. The code will output a .csv excel file with the cleaned data that can
%be opened in R, Python, C++ etc, located at the current folder. The code provides
%a .csv file for each day, and a "masterData" .csv file containing data for 
%all days. Each day .csv file is for verification purposes. 
%For R: read.csv('MasterData.csv', header = TRUE). 
%
%3. We follow the data-cleaning guide from "Realised Kernels in Practice: Trades
%and Quotes" by Asger Lunde et al. 
%
%4. P1,P2,P3,Q1,Q2,Q3,T1,T2,T3,T4 have been implemented
%
%Furthermore it outputs a summary statistic that includes the number of
%data-points lost with each rule. 
%
%
%
%
% 
%
myFolder = 'C:\TAQ\S\SPY';
if exist(myFolder, 'dir') ~= 7
  Message = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(Message));
  return;
end
filePattern = fullfile(myFolder, '*.mat');
matFiles   = dir(filePattern);

quoteFolder = 'C:\TAQ\S\SPY\Quotes';
filePattern = fullfile(quoteFolder, '*.mat');
dataForQuotes = dir(quoteFolder);
dataForQuotes(2) = [];
dataForQuotes(1) = [];

masterData = string(zeros(23400, 2, length(matFiles)));
MasterColumnNames = string(zeros(1,2,length(matFiles)));

summaryStatistics = zeros(length(matFiles), 13); 

sumColNames = zeros(length(matFiles), 13);


for k = 1:length(matFiles)
  baseFileName = matFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf('Now reading %s\n', fullFileName);
  load(fullFileName);
  
  baseFileName2 = dataForQuotes(k).name;
  fullFileName2 = fullfile(quoteFolder, baseFileName2);
  fprintf('Now reading %s\n', fullFileName2);
  quotes = load(fullFileName2, '-mat');
  
  

%----------------------START OF DATA CLEANING:-----------------------------
format long
x = double(TAQdata.utcsec)*1e-9;
dt = datestr(x/86400, 'HH:MM:SS'); %FFF is for millisecond
%86400 is number of seconds in a day. 

time = (double(TAQdata.utcsec)*1e-9);
time = time/86400;


%dt is datetime, Clockwise. 
data = [dt, time, TAQdata.price, double(TAQdata.volume),string(TAQdata.ex), TAQdata.cond, str2num(TAQdata.corr)];  


quotetime = (double(quotes.TAQdata.utcsec)*1e-9)/86400;

quoteData = [quotetime, double(quotes.TAQdata.bid), double(quotes.TAQdata.ofr), string(quotes.TAQdata.ex)];

%--------------------------------P1--------------------------------------
%DELETE ENTRIES BEFORE 9:30 AND 16:00:

%FIND INDEX OF 9:30 IS FOUND USING THE CORRESPONDING UTCSEC VALUE 0.39584:

first_index = find(double(data(1:end,2)) < 0.39584);

first_indexQuotes = find(double(quoteData(1:end,1)) < 0.39584);

%DELETING THE DATA:
data( first_index, :) = [];

quoteData ( first_indexQuotes, :) = [];

%FIND INDEX OF 16:00 IS DONE USING THE CORRESPONDING UTCSEC VALUE 0.66667:
last_index = find(double(data(1:end,2)) > 0.66667);

last_indexQuotes = find(double(quoteData(1:end,1)) > 0.66667);

P1 = size(first_index,1)+size(last_index,1);
P1Q = size(first_indexQuotes,1)+size(last_indexQuotes,1);


%DELETING THE DATA:
data( last_index, :) = [];
quoteData( last_indexQuotes, :) = [];
%------------------------------P2-----------------------------------------
%FINDING TRANSACTION PRICES EQUAL TO ZERO:
locate = find(double(data(1:end, 3)) <= 0);

locateAsk = find(double(quoteData(1:end, 3)) <=0 );
locateBid = find(double(quoteData(1:end, 2)) <=0 );

locateQuotes = unique(sort( [locateBid; locateAsk], 'ascend')); 


%CHECK (SHOULD BE ZERO PRICES):
index_price = double(data( (locate) , 3));

%DELETE ROWS:
data( (locate), :) = [];
quoteData( (locateQuotes) , :) = [];

%How many points are removed in p2. 
P2 = size(locate, 1);

P2Q = size(locate, 1);

%------------------------------P3-----------------------------------------
%WE WILL USE DATA FROM THE THREE HIGHEST EXCHANGES (NOT BASED ON VOLUME
% BUT ON NUMBER OF TRADES EXECUTED)

%Changed to choose trades from NYSE and NASDAQ per Kims recommendation. 

NYSE = sum(count(data(1:end,5), "N"));
Boston = sum(count(data(1:end,5), "B"));
Arca = sum(count(data(1:end,5), "P"));
ISNX = sum(count(data(1:end,5), "C"));
NASDAQ = sum(count(data(1:end,5), "T"));
NASD_ADF = sum(count(data(1:end,5), "D"));
Philadelphia = sum(count(data(1:end,5), "X"));
ISE = sum(count(data(1:end,5), "I"));
Chicago = sum(count(data(1:end,5), "M"));
CBOE = sum(count(data(1:end,5), "W"));
BATS = sum(count(data(1:end,5), "Z"));
C = ["N" "B" "P" "C" "T" "D" "X" "I" "M" "W" "Z"];
C2 =["N" "T"];
%NUMBER OF TRADES:

num_trades = [NYSE Boston Arca ISNX NASDAQ NASD_ADF Philadelphia ISE Chicago CBOE BATS];
num_trades2 = [NYSE NASDAQ];
%ASCENDING ORDER:

[big, idx] = sort(num_trades2, 'descend');
 Highest_tradeexecute = C2(idx);
 Highest_tradeexecute(2,:) = num2cell(big);


%FINIDNG INDIXES FOR NASDAQ AND NYSE (OR THE FIRST 3) EXCHANGES:

first_ex = find(data(1:end,5) == Highest_tradeexecute(1,1));
second_ex = find(data(1:end,5) == Highest_tradeexecute(1,2));
%third_ex = find(data(1:end,5) == Highest_tradeexecute(1,3));

%quote data:
first_exQuotes = find(quoteData(1:end,4) == Highest_tradeexecute(1,1));
second_exQuotes = find(quoteData(1:end,4) == Highest_tradeexecute(1,2));


%SORTING THEM IN ASCENDING ORDER:

%index_new = [first_ex ; second_ex ; third_ex];
index_new2 =[first_ex ; second_ex];

newindex = sort(index_new2, 'ascend');
newindexQuotes = sort( [first_exQuotes ; second_exQuotes], 'ascend');


%how many points lost after selecting exhanges:

P3 =  size(data,1) - size(newindex,1); 
P3Q = size(quoteData,1) - size(newindexQuotes,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data = data( (newindex(1:end,1)), :);
quoteData = quoteData( (newindexQuotes(1:end, 1)), :);

%--------------------------------Q1--------------------------------------
%REPLACE WITH MEDIAN BID AND ASK PRICE WHEN MULTIPLE TIME STAMPS. 

%GIVES THE UNIQUE ELEM IN TIME:
[~,~,X] = unique(quoteData(:,1));

%ACCUMULATES THE DATA TOGETHER WITH THE UNIQUE TIME:
D_bid = accumarray(X,1:size(quoteData,1),[],@(r){double(quoteData(r,2))});

D_ask = accumarray(X,1:size(quoteData,1),[],@(r){double(quoteData(r,3))});

D_bid_temp = zeros(size(D_bid, 1), 1);
D_ask_temp = zeros(size(D_bid, 1), 1);

for i = 1:size(D_bid,1)
   
    D_bid_temp(i,1) = median(D_bid{i});
    D_ask_temp(i,1) = median(D_ask{i});
   
end

%%%
Q1 = size(quoteData,1) - size(D_bid,1);
%%%

quoteData = [unique(quoteData(:,1)) D_bid_temp D_ask_temp];

%--------------------------------Q2--------------------------------------
%DELETE NEGATIVE SPREAD:

bidask_spread = double(quoteData(:,3)) - double(quoteData(:,2));

neg_spread = find(bidask_spread <= 0);

quoteData( neg_spread, :) = [];

Q2 = size(neg_spread,1);

%--------------------------------Q3--------------------------------------
%DELETE SPREAD IF 50 TIMES HIGHER THAN MEDIAN SPREAD FOR THE DAY. OUTLIER
%DETECTION. 

median_spread = median( bidask_spread );

outlier_spreadindex = find( bidask_spread > 50 * median_spread);

Q3 = size(outlier_spreadindex, 1);

quoteData(  outlier_spreadindex, :) = [];


%-------------------------------Q4---------------------------------------
%NOT IMPLEMENTED. HOPEFULLY IT DOESN'T REALLY MATTER.
%-------------------------------T1----------------------------------------
iii = 1:size(data,1);
%FINDING INDIXES WHERE CORR IS NOT EQUAL TO ZERO:
locate = [find(str2num(TAQdata.corr( (iii) ,:)) ~= 0)];

%CHECK (SHOULD BE NONZERO ENTRIES)
%indexcorr_nonzero = str2num(TAQdata.corr(locate,:));

%DELETE ROWS IN ORIGINAL DATA:

data( (locate), : ) = [];

T1 = size(locate, 1);
%--------------------------------T2--------------------------------------
%REMOVING ENTRIES WITH ABNORMAL SALES CONDITIONS, EVERYTHING BESIDES " ",
%"@", "E" AND "F". 

Good_sales = ["    ",  "@   ", " E  ", " F  "];

%FIND VALUES IN DATA EQUAL TO VALUES IN GOOD_SALES, CREATES LOGIC VECTOR:
Good_sales_temp = ismember(data(1:end, 6), Good_sales);

%FIND INDEX IN DATA:
Good_sales_index = find(Good_sales_temp);


T2 = size(data,1) - size(Good_sales_index,1);


%SET DATA EQUAL TO INDEXES:
data = data( Good_sales_index, :);


%--------------------------------T3--------------------------------------
%Multiple time stamps we use median price. 

%GIVES THE UNIQUE ELEM IN TIME:
[~,~,X] = unique(data(:,1));

%ACCUMULATES THE DATA TOGETHER WITH THE UNIQUE TIME:
D_price = accumarray(X,1:size(data,1),[],@(r){double(data(r,3))});

D_vol = accumarray(X,1:size(data,1),[],@(r){double(data(r,4))});

D_dt = accumarray(X,1:size(data,1),[],@(r){double(data(r,2))});

D_price_temp = zeros(size(D_price, 1), 1);
D_vol_temp = zeros(size(D_price, 1), 1);
D_dt_temp = zeros(size(D_price, 1), 1);

for i = 1:size(D_price,1)
   
    D_price_temp(i,1) = median(D_price{i});
    D_vol_temp(i,1) = sum(D_vol{i});
    D_dt_temp(i,1) = mean(D_dt{i});
    
end

T3 = size(data,1) - size(D_price,1);

data = [unique(data(1:end,1))  D_dt_temp D_price_temp D_vol_temp];

%----------------------------------T4--------------------------------------
%DELETE PRICES ABOVE ASK + SPREAD AND PRICES BELOW BID - SPREAD. ONLY
%TESTED ON THE POSITIONS FOR THE SAME TIME STAMPS. AKA SOMETIMES NOT THE
%FULL DATASET SINCE TRADE DATA AND QUOTE DATA DIFFERS IN LENGTH.


%constructing the same length for both of the data sets. 
[val,pos]=intersect(quoteData(:,1), data(:,2));

 
data_tempquotes = quoteData( pos, :);

bidask_spread_temp = bidask_spread( pos, :);

[~,pos2] = intersect(data(:,2), data_tempquotes(:,1));

data_temptrades = data( pos2, :);

%if size(quoteData,1) ~= size(data,1)
 % Message = sprintf('Error: The length of quote data and trade data differs.');
  %uiwait(warndlg(Message));
  %return;
%end


%CURRENTLY SET TO ACCEPTING THE INDDICES UNDER THE VIOLATIONS.
above2 = find( double(data_temptrades(:,3)) <= double(data_tempquotes(:,3)) + bidask_spread_temp);

below2 = find( double(data_temptrades(:,3)) >= double(data_tempquotes(:,2)) - bidask_spread_temp);



%above = find( double(data_temptrades(:,3)) > double(data_tempquotes(:,3)) + bidask_spread_temp);

%below = find( double(data_temptrades(:,3)) < double(data_tempquotes(:,2)) - bidask_spread_temp);

%index_deletion = sort( [above; below], 'ascend' );



index_acceptation = unique(sort( [above2;below2], 'ascend'));

T4 = size(data,1) - size(index_acceptation,1);

%T4 = size(index_deletion,1);

data = data( index_acceptation, :); 

%data( index_deletion, :) = [];


data(:,2) = [];

%--------------------------CSV Conversion step-----------------------------
ColumnName = {strrep(baseFileName,'.mat',''),'Price','Volume'};



masterData(1:size(data,1),:,k) = data(:,1:2);

masterColumnNames(1,:,k) = ColumnName(1:2);

dataTable = array2table(data,'VariableNames',ColumnName);


%WRITING .csv FILE TO CURRENT FOLDER.
%writematrix(data, [strrep(baseFileName,'.mat','') '.csv'] )
%writetable(dataTable, [strrep(baseFileName,'.mat','') '.csv'] )

%%%%%%%%%%%%%%%%%%%%%%For summary statistics%%%%%%%%%%%%%%%%%%%

summary = [T1 T2 T3 T4 Q1 Q2 Q3 P1 P1Q P2 P2Q P3 P3Q];

summaryStatistics(k,:) = summary(1,:);

names = ["T1", "T2", "T3", "T4", "Q1", "Q2", "Q3", "P1", "P1Q", "P2", "P2Q", "P3", "P3Q"];


end


masterData(double(masterData) ==0) = NaN;

%Matlab does not support dublicate row and column names. 
masterData = vertcat(masterColumnNames, masterData);

sumstat = [names; summaryStatistics];

writematrix(masterData, ['MasterData', '.csv']);

writematrix(sumstat, ['SummaryStatisticsforcleaning', '.csv']);