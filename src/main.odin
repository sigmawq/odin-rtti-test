package main

import "core:reflect"
import "core:fmt"

My_Int :: distinct int

Some_Enum :: enum {
	ENUM_VALUE_1,
	ENUM_VALUE_2,
	ENUM_VALUE_3,
}

Baz :: struct {
	field1: int,
	field2: int,
}

Some_Union :: union {
	int,
	bool,
	f32,
	Baz,
}

Foo :: struct {
	a: My_Int,
	b: [2]int,
	c: f64,
	d: Baz,
	e: Some_Enum,
	f: bit_set[Some_Enum;u32],
	g: [dynamic]int,
	h: string,
	i: string,
	k: bool,
	n: Some_Union,
}

Bar :: [2]Foo

fl :: fmt.println

dive :: proc(value: any, depth := 0) {
	using reflect

	// fmt.println("Depth is now ", depth)

	data, id := any_data(value)
	info := type_info_of(id)

	#partial switch v in info.variant {
		case Type_Info_Named:
			fmt.println(v.name, "{")
			next := any { data = value.data, id = v.base.id }
			dive(next)
			fmt.println("}")
		case Type_Info_Struct:
			for field_name in v.names {
				value := struct_field_value_by_name(value, field_name)

				fmt.printf("%v = ", field_name)

				dive(value, depth+1)
				fmt.print("\n")
			}
		case Type_Info_Integer:
			core := type_info_core(type_info_of(id))
			switch core.id {
				case int:
					fmt.print("It's int")
				case:
					fmt.panicf("%#v", value.id)
			}
		case Type_Info_Float:
			core := type_info_core(type_info_of(id))
			switch core.id {
				case f64:
					fmt.print("It's f64")
				case f32:
					fmt.print("It's f32")
				case:
					fmt.panicf("%#v", value.id)
			}
		case Type_Info_Array:
			fmt.print("[")
			defer fmt.print("]") 

			for i in 0..<v.count {
				next := any { 
					data = rawptr(cast(uintptr)(value.data) + cast(uintptr)(v.elem_size * i)),  
					id = v.elem.id,
				}

				// data := uintptr(array_data) + uintptr(i*elem_size)
				// fmt_arg(fi, any{rawptr(data), elem_id}, verb)

				dive(next)
				fmt.print(",")
			}
		case Type_Info_Dynamic_Array:
			fmt.print("[")
			len := length(value)
			cap := capacity(value)
			for i in 0..<len {
				next := any { 
					data = rawptr(cast(uintptr)(value.data) + cast(uintptr)(v.elem_size * i)),  
					id = v.elem.id,
				}

				dive(next)
				fmt.print(",")
			}

			fmt.print("]")
		case Type_Info_Slice:
			fmt.print("[")
			len := length(value)
			cap := capacity(value)
			for i in 0..<len {
				next := any { 
					data = rawptr(cast(uintptr)(value.data) + cast(uintptr)(v.elem_size * i)),  
					id = v.elem.id,
				}

				dive(next)
				fmt.print(",")
			}

			fmt.print("]")
		case Type_Info_Enum:
			fmt.println(enum_string(value))
		case Type_Info_Bit_Set:
			names: []string
			values: []Type_Info_Enum_Value
			ty_named, is_named := v.elem.variant.(Type_Info_Named)
			ty_enum, is_enum := v.elem.variant.(Type_Info_Enum)
			if is_named {
				ty_enum = ty_named.base.variant.(Type_Info_Enum)
			} else if is_enum {
			} else {
				fmt.panicf("%#v", v.elem)
			}

			for name, i in ty_enum.names {
				if ((transmute(^u64)(value.data))^ & (1 << u64(ty_enum.values[i]))) > 0 {
					fmt.println("ON: ", name)
				} else {
					fmt.println("OFF: ", name)
				}
			}
		case Type_Info_String:
			if v.is_cstring {
				panic("Not supported")
			}

			str := (transmute(^string)(value.data))^
			fmt.print("(string) ")
			fmt.print("\"", str, "\"")
		case Type_Info_Boolean:
			boolean := (transmute(^bool)(value.data))^
			fmt.print(boolean)
		case Type_Info_Union:
			using v

			assert(tag_type.id == u64)
			tag := int((transmute(^u64)(uintptr(value.data) + uintptr(tag_offset)))^) - 1
			if no_nil || shared_nil || custom_align {
				panic("Not supported")
			}

			if tag == -1 {
				fmt.print("(nil)")
				return				
			}

			variant := variants[int(tag)]
			next := any { 
				data = value.data,
				id = variant.id
			}

			dive(next)				
		case:
			fmt.panicf("%#v", info.variant)
	}
}

main :: proc() {
	using reflect

	foo: Foo
	foo.f = bit_set[Some_Enum; u32]{ .ENUM_VALUE_2, .ENUM_VALUE_3 }

	append(&foo.g, 25)
	append(&foo.g, 666)
	append(&foo.g, 1488)
	foo.h = "1231231231212sfgstring tihs "
	foo.n = nil
	dive(foo)
	// bar: Bar	
	// value: any = bar	
	// data, id := any_data(value)
	// base := type_info_base(type_info_of(id))
	// core := type_info_core(type_info_of(id))

	// #partial switch v in base.variant {
	// 	case Type_Info_Struct:
	// 		for field_name in v.names {
	// 			value := struct_field_value_by_name(value, field_name)
	// 			fmt.println(field_name, "=", value)

	// 			field_base := type_info_base(type_info_of(value.id))

	// 		}
	// 	case Type_Info_Array:
	// 		for i in 0..<v.count {
	// 			switch b in v.elem.variant {
	// 				case Type_Info_Integer:

	// 				case:
	// 					fmt.panicf("%#v", v.elem)
	// 			}
	// 		}
	// 	case:
	// 		fmt.panicf("%#v", base.variant)
	// }

}