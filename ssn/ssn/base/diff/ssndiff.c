//
//  ssn_diff.c
//  ssn
//
//  Created by lingminjun on 14/12/16.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "ssndiff.h"
#include <stdlib.h>
#include <string.h>

#ifdef DEBUG
#include <stdio.h>
#endif

typedef struct {
    size_t row;
    size_t col;
    size_t *table;
} ssn_diff_lcs_table_t;

ssn_diff_lcs_table_t *ssn_diff_create_table(size_t row, size_t col) {
    ssn_diff_lcs_table_t *table = (ssn_diff_lcs_table_t *)malloc(sizeof(ssn_diff_lcs_table_t));
    table->row = row;
    table->col = col;
    table->table = malloc(sizeof(size_t)*row*col);
    memset(table->table, 0, (sizeof(size_t)*row*col));
    return table;
}

void ssn_diff_destroy_table(ssn_diff_lcs_table_t *table) {
    free(table->table);
    free(table);
}

size_t ssn_diff_table_value(const ssn_diff_lcs_table_t *table, size_t row, size_t col) {
    return *(table->table + row * table->col + col);
}

void ssn_diff_table_value_set(const ssn_diff_lcs_table_t *table, size_t row, size_t col, size_t value) {
    *(table->table + row * table->col + col) = value;
}

ssn_diff_lcs_table_t *ssn_diff_lcs_table(void *from, void *to, const size_t f_size, const size_t t_size, ssn_diff_element_is_equal equal_func, void *context)
{
    const size_t rowSize = f_size + 1;
    const size_t colSize = t_size + 1;
    ssn_diff_lcs_table_t *table = NULL;
    size_t row = 1, col = 1;
    size_t value0 = 0, value1 = 0, value2 = 0;
    
    table = ssn_diff_create_table(rowSize, colSize);
    
    for (row = 1; row < rowSize; row++)
    {
        for (col = 1; col < colSize; col++)
        {
            value0 = ssn_diff_table_value(table, row - 1, col - 1);
            value1 = ssn_diff_table_value(table, row, col - 1);
            value2 = ssn_diff_table_value(table, row - 1, col);
            
            if (equal_func(from, to, row - 1, col - 1, context)) {//可能成为瓶颈
                ssn_diff_table_value_set(table, row, col, (value0 + 1));
            }
            else if (value1 >= value2) {
                ssn_diff_table_value_set(table, row, col, value1);
            }
            else {
                ssn_diff_table_value_set(table, row, col, value2);
            }
        }
    }
    
    return table;
}

//不断压栈，防止栈溢出，此处逻辑需要改，递归不是很好的做法
void ssn_diff_results_enumerate(ssn_diff_lcs_table_t *table,void *from, void *to, const size_t row, const size_t col,ssn_diff_results_iterator iterator_func, void *context) {
    
    size_t value0 = 0,value1 = 0, value2 = 0;
    
    value0 = ssn_diff_table_value(table, row, col);
    value1 = ssn_diff_table_value(table, row, col - 1);
    value2 = ssn_diff_table_value(table, row - 1, col);
    
    if (row > 0 && col > 0 && value1 == value2 && value0 > value1) {
        ssn_diff_results_enumerate(table, from, to, row - 1, col - 1, iterator_func, context);
        iterator_func(from, to, row - 1, col - 1, ssn_diff_no_change, context);
        //printf("  %c\n",s1[row - 1]);
    }
    else if (col > 0 && (row == 0 || value1 >= value2)) {
        ssn_diff_results_enumerate(table, from, to, row, col - 1, iterator_func, context);
        iterator_func(NULL, to, UINT64_MAX, col - 1, ssn_diff_insert, context);
        //printf("+ %c\n",s2[col - 1]);
    }
    else if (row > 0 && (col == 0 || value1 < value2)) {
        ssn_diff_results_enumerate(table, from, to, row - 1, col, iterator_func, context);
        iterator_func(from, NULL, row - 1, UINT64_MAX, ssn_diff_delete, context);
        //printf("- %c\n",s1[row - 1]);
    }
}

//算法待优化//2015-3-13，用空间转换，内存转移到堆中
void ssn_diff_results_enumerate_v2(ssn_diff_lcs_table_t *table,void *from, void *to, const size_t f_size, const size_t t_size,ssn_diff_results_iterator iterator_func, void *context) {
    
    size_t value0 = 0,value1 = 0, value2 = 0;
    size_t row = f_size, col = t_size;//游标
    
    size_t *row_queue = NULL;
    size_t *col_queue = NULL;
    ssn_diff_change_type *type_queue = NULL;
    
    const size_t max_queue_count = f_size + t_size;
    
    size_t queue_index = 0;
    
    row_queue = malloc(sizeof(size_t)*max_queue_count);
    memset(row_queue, 0, sizeof(size_t)*max_queue_count);
    
    col_queue = malloc(sizeof(size_t)*max_queue_count);
    memset(col_queue, 0, sizeof(size_t)*max_queue_count);
    
    type_queue = malloc(sizeof(ssn_diff_change_type)*max_queue_count);
    memset(type_queue, 0, sizeof(ssn_diff_change_type)*max_queue_count);
    
    while (row > 0 || col > 0) {
        
        //从table中取规划值
        value0 = ssn_diff_table_value(table, row, col);
        value1 = ssn_diff_table_value(table, row, col - 1);
        value2 = ssn_diff_table_value(table, row - 1, col);
        
        if (row > 0 && col > 0 && value1 == value2 && value0 > value1) {
            
            row--;
            col--;
            
            row_queue[queue_index] = row;
            col_queue[queue_index] = col;
            type_queue[queue_index] = ssn_diff_no_change;
            queue_index++;
        }
        else if (col > 0 && (row == 0 || value1 >= value2)) {
            
            col--;
            
            row_queue[queue_index] = UINT64_MAX;
            col_queue[queue_index] = col;
            type_queue[queue_index] = ssn_diff_insert;
            queue_index++;
        }
        else if (row > 0 && (col == 0 || value1 < value2)) {
            
            row--;
            
            row_queue[queue_index] = row;
            col_queue[queue_index] = UINT64_MAX;
            type_queue[queue_index] = ssn_diff_delete;
            queue_index++;
        }
    }
    
    for (; queue_index > 0; queue_index--) {
        if (type_queue[queue_index - 1] == ssn_diff_no_change) {
            iterator_func(from, to, row_queue[queue_index - 1], col_queue[queue_index - 1], ssn_diff_no_change, context);
        }
        else if (type_queue[queue_index - 1] == ssn_diff_insert) {
            iterator_func(NULL, to, row_queue[queue_index - 1], col_queue[queue_index - 1], ssn_diff_insert, context);
        }
        else if (type_queue[queue_index - 1] == ssn_diff_delete) {
            iterator_func(from, NULL, row_queue[queue_index - 1], col_queue[queue_index - 1], ssn_diff_delete, context);
        }
    }
    
    free(row_queue);
    free(col_queue);
    free(type_queue);
}

void ssn_diff(void *from, void *to, const size_t f_size, const size_t t_size, ssn_diff_element_is_equal equal_func, ssn_diff_results_iterator iterator_func, void *context) {

    ssn_diff_lcs_table_t *table = NULL;
    size_t idx = 0;
    
    if (NULL == iterator_func || (f_size == 0 && t_size == 0)) {//没有迭代器，等于白忙活，没有数据也是白忙活
        return ;
    }
    
    if (f_size > 0 && t_size == 0) {//仅仅删除
        if (NULL == from) {
            return ;
        }
        
        for (idx = 0; idx < f_size; idx++) {
            iterator_func(from, NULL, idx, UINT64_MAX, ssn_diff_delete, context);
        }
        
        return ;
    }
    
    if (f_size == 0 && t_size > 0) {//仅仅
        if (NULL == to) {
            return ;
        }
        
        for (idx = 0; idx < t_size; idx++) {
            iterator_func(NULL, to, UINT64_MAX, idx, ssn_diff_insert, context);
        }
        
        return ;
    }
    
    if (NULL == equal_func) {//无法比较数据，无法计算
        return ;
    }
    
    table = ssn_diff_lcs_table(from, to, f_size, t_size, equal_func, context);
    
    if (!table) {
        return ;
    }
    
    //ssn_diff_results_enumerate(table, from, to, f_size, t_size, iterator_func, context);

    ssn_diff_results_enumerate_v2(table, from, to, f_size, t_size, iterator_func, context);
        
    ssn_diff_destroy_table(table);
}
