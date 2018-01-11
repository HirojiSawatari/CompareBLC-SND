#define GSL_DLL
#define _USE_MATH_DEFINES
#include <math.h>
#include <gsl/gsl_integration.h>
#include <iostream>
#include <fstream>
// #include <omp.h>

using namespace std;

double f (double T, void * params) {
  double TCA = *(double *) params;
  double s = 5.5;
  double f = T/(s*sqrt(2*M_PI))*exp(-(T-TCA)*(T-TCA)/(2*s*s));	//d(PDD)的原函数 
  return f;
}

double min (double x, double y){
	if (x<y) return x;
	else return y;
}

int main(void)
{
	int a,b,c;   // p[12][128][256]
    
    double ***p;	//三维数组 
    p = new double **[12]; 
	for(a=0; a<12; a++) 
    { 
        p[a] = new double *[128]; 
        for(b=0; b < 128; b ++) 
            p[a][b] = new double[256]; 
    }
   
	
//    double data[12][128][256];
    ifstream dataFile;
    dataFile.open("re_monthlydata.txt");
    int i,j,k;
    for (i=0;i<12;i++) {
        for (j=0;j<128;j++) {
            for (k=0;k<256;k++) {
                dataFile >> p[i][j][k];	//输入re_monthlydata值到p 
            }
        }
    }
    dataFile.close();	//输入数据至p 

// 	Surface type % glacier
	double **sftgif;	//二维数组 
    sftgif = new double *[128]; 
	for(a=0; a<128; a++) 
    { 
        sftgif[a] = new double [256]; 
    }
	// double sftgif[128][256];
	
	ifstream dataFile_sft;
    dataFile_sft.open("re_sft.txt");
	for (j=0;j<128;j++) {
		for (k=0;k<256;k++) {
                dataFile_sft >> sftgif[j][k];	//赋值re_sft到sftgif 
            }
        }
    dataFile_sft.close();

	/*
	for (i=0;i<50;i++)
		cout << sftgif[1][i]<< endl;
		*/

	// Total Precipitation

	double **pr;	//二维数组 
    pr = new double *[128]; 
	for(a=0; a<128; a++) 
    { 
        pr[a] = new double [256]; 
    }

	//double pr[128][256];
	
	ifstream dataFile_pr;
    dataFile_pr.open("tpr.txt");
	for (j=0;j<128;j++) {
		for (k=0;k<256;k++) {
                dataFile_pr >> pr[j][k];	//赋值tpr到pr 
            }
        }
    dataFile_pr.close();
	
//	cout<<p[1][1][1]<< endl;
//	cout << sftgif[1][1] <<endl;


	// Total Snowfall
	
	double **prsn;	//二维数组 
    prsn = new double *[128]; 
	for(a=0; a<128; a++) 
    { 
        prsn[a] = new double [256]; 
    }
	
//	double prsn[128][256];

	ifstream dataFile_prsn;
    dataFile_prsn.open("tprsn.txt");
	for (j=0;j<128;j++) {
		for (k=0;k<256;k++) {
                dataFile_prsn >> prsn[j][k];	//赋值tprsn到prsn 
            }
        }
    dataFile_prsn.close();

/*
    cout << "The data output Jan (1,1):" << data[0][0][0] << endl;
    cout << "The data output Jan (1,2):" << data[1][0][0] << endl;
    cout << "The data outout Jan (1,3):" << data[2][0][0] << endl;
    cout << "The data outout Jan (1,4):" << data[3][0][0] << endl;
    cout << "The data outout Jan (2,1):" << data[0][1][0] << endl;
    cout << "The data outout Jan (3,1):" << data[0][2][0] << endl;
    cout << "The data outout Jan (4,1):" << data[0][3][0] << endl;
    cout << "The data outout Feb (1,1):" << data[0][0][1] << endl;

*/
/*
    cout<< "The data output of Jan with lat = 0 :" <<endl;
    for (int m=0;m<10;m++)
    {
        cout << data[0][0][m] << endl;
    }

    cout<< "The data output of Jan with lat = 1 :" <<endl;
    for (int m=0;m<12;m++)
    {
        cout << data[0][1][m] << endl;
    }
*/
// That is the correct output and we get the 3D array [month][lat][lon]
// We calculate the monthly PDD in the following code

	/*double **output;
    output = new double *[128]; 
	for(a=0; a<128; a++) 
    { 
        output[a] = new double [256]; 
    }
	*/
	//重点 
    double output[128][256];	//output二维矩阵 

    double result, error;
    size_t neval;
    gsl_function F;
    F.function = &f;
//#pragma omp parallel for private(F,j,k,result)
    for (j=0;j<128;j++) {
        for (k=0;k<256;k++) {
            output[j][k] = 0;
            for (i=0;i<12;i++) {
                F.params = &p[i][j][k];	//re_monthlydata 
                gsl_integration_qng (&F, 0, 100, 0.01, 0, &result, &error, &neval);	//非自适应gauss-krondrod积分 
                output[j][k] += result;
            }
        }
    }

	double out[128][256];

	for (j=0;j<128;j++) {
		for (k=0;k<256;k++) {
			out[j][k] = output[j][k] * 30;	//乘以30,30天？ 
		}
	}
	/*
	double **MSnow;
    MSnow = new double *[128]; 
	for(a=0; a<128; a++) 
    { 
        MSnow[a] = new double [256]; 
    }
	*/
	//融雪
	double MSnow[128][256];
	double Tjja = 0;
	for (j=0;j<128;j++) {
        for (k=0;k<256;k++) {

			Tjja = (p[5][j][k]+p[6][j][k]+p[7][j][k]);	//六七八月相加 
			if (Tjja <= -1)	//JJA平均温度小于等于-1 
MSnow[j][k]=2.99*out[j][k];
			else if(Tjja > -1 && Tjja <10)	//JJA平均温度在-1到10之间 
MSnow[j][k]=(0.015*Tjja)+(3.22*out[j][k]);
			else	//JJA平均温度大于等于10 
MSnow[j][k]=4.81*out[j][k];
		}
	}

	/*
	double **MIce;
    MIce = new double *[128]; 
	for(a=0; a<128; a++) 
    { 
        MIce[a] = new double [256]; 
    }
	*/
	
	//融冰
	double MIce[128][256];
	for (j=0;j<128;j++) {
        for (k=0;k<256;k++) {
			Tjja = (p[5][j][k]+p[6][j][k]+p[7][j][k]);
			if (Tjja <= -1)
MIce[j][k]=9.29*out[j][k];
			else if(Tjja > -1 && Tjja <10)
MIce[j][k]=(0.0067*(10-Tjja)*(10-Tjja)*(10-Tjja))+(9.32*out[j][k]);
			else
MIce[j][k]=19.28*out[j][k];
		}
	}



	// Total Balance
	double **BLC;	//二维数组 
    double **AT;	//记录温度部分
	double **PR;	//记录降雨/雪部分
	BLC = new double *[128]; 
	AT = new double *[128]; 
	PR = new double *[128]; 
	for(a=0; a<128; a++) 
    { 
        BLC[a] = new double [256]; 
		AT[a] = new double [256];
		PR[a] = new double [256];
    }
	// double BLC[128][256];
	for (j=0;j<128;j++) {
        for (k=0;k<256;k++) {

			if (sftgif[j][k] == 0)	//re_sft的值等于0，不是冰盖
			{
				if (pr[j][k]-prsn[j][k] < 0)	//降雨小于降雪
				{
					BLC[j][k] = -MSnow[j][k];
					AT[j][k] = MSnow[j][k];
					PR[j][k] = 0;
				}
				else	//降雨大于降雪（下雪量减去融雪量）
				{ 
					BLC[j][k] = prsn[j][k] - MSnow[j][k];
					AT[j][k] = MSnow[j][k];
					PR[j][k] = prsn[j][k];
				}
			}
			else	//冰盖（降水全变成冰，减去融雪）
			{
				BLC[j][k] = pr[j][k] - MSnow[j][k] - MIce[j][k];
				AT[j][k] = MSnow[j][k] + MIce[j][k];
				PR[j][k] = pr[j][k];
			}
		}
	}

	


	ofstream outFile_Balance;
	ofstream outFile_AT;
	ofstream outFile_PR;
    outFile_Balance.open("balance.txt");
	outFile_AT.open("AT.txt");
	outFile_PR.open("PR.txt");
    for (i=0;i<128;i++) {
        for (j=0;j<256;j++) {
            outFile_Balance << BLC[i][j] << ' ';
			outFile_AT << AT[i][j] << ' ';
			outFile_PR << PR[i][j] << ' ';
        }
        outFile_Balance << endl;
        outFile_AT << endl;
        outFile_PR << endl;
    }
    outFile_Balance.close();
	outFile_AT.close();
	outFile_PR.close();

/*
    cout<< "The data output:" <<endl;
    for (int m=0;m<10;m++)
    {
        cout << output[0][m] << endl;
    }

*/

    ofstream outFile;
    outFile.open("re_output.txt");
    for (i=0;i<128;i++) {
        for (j=0;j<256;j++) {
            outFile << out[i][j] << ' ';
        }
        outFile << endl;
    }
    outFile.close();

	/*
	ofstream outFile_MS;
    outFile_MS.open("MSnow.txt");
    for (i=0;i<128;i++) {
        for (j=0;j<256;j++) {
            outFile_MS << MSnow[i][j] << ' ';
        }
        outFile_MS << endl;
    }
    outFile_MS.close();

	ofstream outFile_MI;
    outFile_MI.open("MIce.txt");
    for (i=0;i<128;i++) {
        for (j=0;j<256;j++) {
            outFile_MI << MIce[i][j] << ' ';
        }
        outFile_MI << endl;
    }
    outFile_MI.close();
	*/

	// Free Memory
	for(a=0; a<12; a++) 
    {
        for(b=0; b<3; b++) 
        {   
            delete [] p[a][b];   
        }   
    }       
    for(a=0; a<12; a++)   
    {       
        delete [] p[a];   
    }   
    delete [] p;  

	
	for(i=0;i<128;i++){ 
		delete []sftgif[i]; 
	} 
	delete []sftgif; 
	
	/*
	for(i=0;i<128;i++){ 
		delete []MSnow[i]; 
	} 
	delete []MSnow;
	*/
/*
	for(i=0;i<128;i++){ 
		delete []MIce[i]; 
	} 
	delete []MIce;
*/
	/*
	for(i=0;i<128;i++){ 
		delete []output[i]; 
	} 
	delete []output; 
	*/
	
	for(i=0;i<128;i++){ 
		delete []BLC[i]; 
		delete []AT[i]; 
		delete []PR[i]; 
	} 
	delete []BLC; 
	delete []AT;
	delete []PR;

	for(i=0;i<128;i++){ 
		delete []pr[i]; 
	} 
	delete []pr; 

	for(i=0;i<128;i++){ 
		delete []prsn[i]; 
	} 
	delete []prsn; 


    return 0;
}
