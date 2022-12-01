package com.study.crm.commons.utils;

import org.apache.poi.hssf.usermodel.HSSFCell;

public class HSSFUtils {
    public static String getCellValueForStr(HSSFCell cell) {
        String str = "";
        if (cell.getCellType() == 0) {
            str = cell.getNumericCellValue()+"";
        } else if (cell.getCellType() == 1) {
            str = cell.getStringCellValue();
        } else if (cell.getCellType() == 4){
            str=cell.getBooleanCellValue()+"";
        }
        return str;
    }
}
