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

Foo :: struct {
	a: My_Int,
	b: [2]int,
	c: f64,
	d: Baz, 
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
		// case Type_Info_Array:
		// 	for i in 0..<v.count {
		// 		switch b in v.elem.variant {
		// 			case Type_Info_Integer:

		// 			case:
		// 				fmt.panicf("%#v", v.elem)
		// 		}
		// 	}
		case:
			fmt.panicf("%#v", info.variant)
	}
}

main :: proc() {
	using reflect

	foo: Foo	
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