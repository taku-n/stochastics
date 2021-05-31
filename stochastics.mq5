#property indicator_separate_window
#property indicator_minimum   0
#property indicator_maximum 100
#property indicator_level1 25
#property indicator_level2 50
#property indicator_level3 75

#property indicator_buffers 3
#property indicator_plots   3

#property indicator_label1 "K"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

#property indicator_label2 "D"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrYellow
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_label3 "SD"
#property indicator_type3  DRAW_LINE
#property indicator_color3 clrCyan
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

input int PERIOD_K  = 9;
input int PERIOD_D  = 3;
input int PERIOD_SD = 3;

double k[];
double d[];
double sd[];

int OnInit()
{
	SetIndexBuffer(0, k, INDICATOR_DATA);
	PlotIndexSetString(0, PLOT_LABEL, "K(" + IntegerToString(PERIOD_K) + ")");    // Data Window

	SetIndexBuffer(1, d, INDICATOR_DATA);
	PlotIndexSetString(1, PLOT_LABEL, "D(" + IntegerToString(PERIOD_D) + ")");    // Data Window

	SetIndexBuffer(2, sd, INDICATOR_DATA);
	PlotIndexSetString(2, PLOT_LABEL, "SD(" + IntegerToString(PERIOD_SD) + ")");  // Data Window

	// Chart Window
	IndicatorSetString(INDICATOR_SHORTNAME,
			"K(" + IntegerToString(PERIOD_K) + "), "
			+ "D(" + IntegerToString(PERIOD_D) + "), "
			+ "SD(" + IntegerToString(PERIOD_SD) + ")");
	IndicatorSetInteger(INDICATOR_DIGITS, 3);

	return INIT_SUCCEEDED;
}

int OnCalculate(const int       TOTAL,
		const int       PREV,
		const datetime &T[],
		const double   &O[],
		const double   &H[],
		const double   &L[],
		const double   &C[],
		const long     &TICK_VOL[],
		const long     &VOL[],
		const int      &SP[])
{
	stochastics(H, L, C, TOTAL, PREV);

	return TOTAL;
}

void stochastics(const double &H[], const double &L[], const double &C[], const int TOTAL,
		const int PREV)
{
	int begin;

	if (PREV == 0) {
		begin = 0;
	} else {
		begin = PREV - 1;
	}

	k(H, L, C, TOTAL, begin);
	d_sd(H, L, C, TOTAL, begin);
}

void k(const double &H[], const double &L[], const double &C[], const int TOTAL, const int BEGIN)
{
	for (int i = BEGIN; i < TOTAL; i++) {
		double lowest = lowest(L, i);
		double highest = highest(H, i);
		if (highest - lowest == 0.0) {
			k[i] = 50.0;
		} else {
			k[i] = ((C[i] - lowest) / (highest - lowest)) * 100.0;
		}
	}
}

void d(const double &H[], const double &L[], const double &C[], const int TOTAL, const int BEGIN)
{
	for (int i = BEGIN; i < TOTAL; i++) {
		double numer = 0.0, denom = 0.0;
		for (int j = i - (PERIOD_D - 1); j <= i; j++) {
			if (j < 0) {
				numer += C[0] - lowest(L, 0);
				denom += highest(H, 0) - lowest(L, 0);
			} else {
				numer += C[j] - lowest(L, j);
				denom += highest(H, j) - lowest(L, j);
			}
		}

		if (denom == 0.0) {
			d[i] = 50.0;
		} else {
			d[i] = (numer / denom) * 100.0;
		}
	}
}

void sd(const int TOTAL, const int BEGIN)
{
	for (int i = BEGIN; i < TOTAL; i++) {
		double sum = 0.0;
		for (int j = i - (PERIOD_SD - 1); j <= i; j++) {
			if (j < 0) {
				sum += d[0];
			} else {
				sum += d[j];
			}
		}
		sd[i] = sum / PERIOD_SD;
	}
}

void d_sd(const double &H[], const double &L[], const double &C[], const int TOTAL, const int BEGIN)
{
	d(H, L, C, TOTAL, BEGIN);
	sd(TOTAL, BEGIN);
}

double lowest(const double &L[], const int I)
{
	double lowest = DBL_MAX;

	for (int i = I - (PERIOD_K - 1); i <= I; i++) {
		if (i < 0) {
			if (L[0] < lowest) {
				lowest = L[0];
			}
		} else {
			if (L[i] < lowest) {
				lowest = L[i];
			}
		}
	}

	return lowest;
}

double highest(const double &H[], const int I)
{
	double highest = 0.0;

	for (int i = I - (PERIOD_K - 1); i <= I; i++) {
		if (i < 0) {
			if (H[0] > highest) {
				highest = H[0];
			}
		} else {
			if (H[i] > highest) {
				highest = H[i];
			}
		}
	}

	return highest;
}
