/// @function spt_convert_letters()
/// @description											Converts number to a letter the same way as you would see on an atlas or a spreadsheet.
/// @param               _number		{Real}      The number to convert to a letter(s).
/// @param               _type			{Real}      The number to convert to a letter(s).
/// @return									{String}   Return letter.
/// @pure

function spt_convert_letters(_number)
{
	if (!is_real(_number)) return undefined;

    var _val = floor(_number);
    var _prefix = (_val < 0) ? "-" : "";
    var _num = abs(_val);
	
	if _number > 0 then _num ++;

    var _string = "";
	
    while (_num > 0)
    {
        _num -= 1; 
        _string = chr((_num mod 26) + 65) + _string;
        _num = _num div 26;
    }

    return _prefix + (_string == "" ? "A" : _string);
}