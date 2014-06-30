//
//  SSNDBSectionImp.m
//  ssn
//
//  Created by lingminjun on 14-5-27.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#import "SSNDBSectionImp.h"

@implementation SSNDBSectionImp

@end

/*
 lcs
 
 
 #include <stdio.h>
 #include <string.h>
 
 #define N 100
 
 char a[N], b[N], str[N];
 int c[N][N];
 
int lcs_len(char* a, char* b, int c[][N])
{
    int m = strlen(a), n = strlen(b), i, j;
    
    for( i=0; i<=m; i++ )
        c[i][0]=0;
    for( i=0; i<=n; i++ )
        c[0][i]=0;
    
    for( i=1; i<=m; i++ )
    {
        for( j=1; j<=n; j++ )
        {
            if (a[i-1]==b[j-1]) {
                c[i][j]=c[i-1][j-1] + 1;
            }
            else if (c[i-1][j]>=c[i][j-1]) {
                c[i][j]=c[i-1][j];
            }
            else {
                c[i][j]=c[i][j-1];
            }
        }
    }
    
    return c[m][n];
}

char* build_lcs(char s[], char* a, char* b)
{
    int i = strlen(a), j = strlen(b);
    int k = lcs_len(a,b,c);
    s[k] = '/0';
    while( k>0 )
    {
        if (c[i][j]==c[i-1][j]) {
            i--;
            printf("-%d %c\n",i,a[i]);
        }
        else if (c[i][j]==c[i][j-1]) {
            j--;
            printf("+%d %c\n",j,b[j]);
        }
        else
        {
            s[--k]=a[i-1];
            i--; j--;
        }
    }
    
    while (i > 0) {
        i--;
        printf("-%d %c\n",i,a[i]);
    }
    
    while (j > 0) {
        j--;
        printf("+%d %c\n",j,b[j]);
    }
    
    return s;
}

int main()
{
    printf("Enter two string (length < %d) :\n",N);
    
    //strcpy(a, "abcdef");
    strcpy(a, "cregtt");
    strcpy(b, "creftt");
    
    //scanf("%s%s",a,b);
    printf("a = %s\n",a);
    printf("b = %s\n",b);
    
    printf("LCS=%s/n",build_lcs(str,a,b));
}
*/
 
