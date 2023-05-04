OUTPUT_ARCH("riscv")
OUTPUT_FORMAT("elf64-littleriscv")

ENTRY(_start)

MEMORY {
	ram (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 32M
}

PHDRS {
	text	PT_LOAD;
	data	PT_LOAD;
	bss	PT_LOAD;
}

SECTIONS {
	.text : {
		PROVIDE( __text_start = . );
		*(.text.init) *(.text .text.*)
		PROVIDE( __text_end = . );
	} > ram AT > ram : text

	.data : {
		. = ALIGN(4096);
		PROVIDE( __data_start = . );
		*(*.sdata .sdata*) *(.data .data.*)
		PROVIDE( __data_end = . );
	} > ram AT > ram : data

	.bss : {
		. = ALIGN(4096);
		PROVIDE( __bss_start = . );
		*(.sbss .sbss.*) *(.bss .bss.*)
		. = ALIGN(4096);
		PROVIDE( __bss_end = . );
	} > ram AT > ram : bss

	PROVIDE( __mem_start = ORIGIN(ram) );
	PROVIDE( __mem_end = ORIGIN(ram) + LENGTH(ram));
}
