// Utility functions
function Int32_ptr() {
	return  new Int32Array(membuf, malloc(4), 1);
}

function deref(ptr) {
	return ptr[0]
}

// Render glyph at index `idx` with size `size`
function render_glyph(idx, size) {

	const glyphptr = Int32_ptr();
	const widthptr = Int32_ptr();
	const heightptr = Int32_ptr();

	instance.exports.render(font_buf.byteOffset, font_buf.length, glyphptr.byteOffset, idx, size, widthptr.byteOffset, heightptr.byteOffset);

	if (membuf.byteLength === 0) {
		return; // Prevent accessing detached buffers
	}

	const width = deref(widthptr)
	free(widthptr.byteOffset)
	const height = deref(heightptr)
	free(heightptr.byteOffset)


	const glyph = new Uint8ClampedArray(
		membuf,
		deref(glyphptr),
		height * width
	)
	free(glyphptr.byteOffset)

	if (!(height > 0) || !(width > 0)) {
		return; // Bounds check
	}

	var canvas = document.getElementById("viewport");
	var context = canvas.getContext("2d");

	context.clearRect(0, 0, canvas.width, canvas.height);
	var imagedata = context.createImageData(width * 4, height * 4);

	for (var y = 0; y < height * 4; y++) {
		for (var x = 0; x < width * 4; x++) {
			// Get the pixel index
			var pixelindex = (y * width * 4 + x) * 4;

			var red = glyph[(Math.floor(y / 4)) * width + Math.floor(x / 4)];
			var green = glyph[(Math.floor(y / 4)) * width + Math.floor(x / 4)];
			var blue = glyph[(Math.floor(y / 4)) * width + Math.floor(x / 4)];

			if (red == 0) {
				imagedata.data[pixelindex + 3] = 0;
			} else {

				// Set the pixel data
				imagedata.data[pixelindex] = 255 - red;     // Red
				imagedata.data[pixelindex + 1] = 255 - green; // Green
				imagedata.data[pixelindex + 2] = 255 - blue;  // Blue
				imagedata.data[pixelindex + 3] = 255;   // Alpha
			}
		}
	}
	context.putImageData(imagedata, canvas.width / 2 - width * 4 / 2, canvas.height / 2 - height * 4 / 2);

	document.getElementById("glyph_idx").innerText = idx;
	document.getElementById("glyph_sz").innerText = size;

	instance.exports.cleanup();
}



async function init() {
	const { instance } = await WebAssembly.instantiateStreaming(
		fetch("./inspect.wasm"), {
		env: {
			setjmp() { return 0 },
			longjmp() { return 0 },
			FT_Trace_Disable() { return 0 },
			FT_Trace_Enable() { return 0 },
		},
		wasi_snapshot_preview1: {
			environ_get() { return 0 },
			environ_sizes_get() { return 0 },
			fd_close() { return 0 },
			fd_fdstat_get() { return 0 },
			fd_fdstat_set_flags() { return 0 },
			fd_prestat_get() { return 0 },
			fd_prestat_dir_name() { return 0 },
			fd_read() { return 0 },
			fd_seek() { return 0 },
			fd_write() { return 0 },
			path_open() { return 0 },
			proc_exit() { return 0 }
		}
	}
	);


	const ttf = await fetch('./LiberationSans-Regular.ttf');
	const font_arr = new Uint8Array(await ttf.arrayBuffer());
	window.instance = instance;
	window.membuf = instance.exports.memory.buffer;
	window.malloc = instance.exports.malloc;
	window.free = instance.exports.free;


	// Turn that sequence of 32-bit integers
	// into a Uint32Array, starting at that address.
	const font_buf = new Uint8Array(
		instance.exports.memory.buffer,
		instance.exports.malloc(font_arr.byteLength),
		font_arr.byteLength
	);

	// Copy the values from JS to C.
	font_buf.set(font_arr);

	window.font_buf = font_buf;

	// // Run the function, passing the starting address and length.
	render_glyph(index, size)
}


function loadFont(event) {
	var input = event.target;

	var reader = new FileReader();
	reader.onload = function () {
		free(font_buf.byteOffset);
		const ft_arr = new Uint8Array(reader.result)
		var ptr = malloc(ft_arr.byteLength)

		// Check for out of memory and grow memory accordingly
		if (ptr + ft_arr.byteLength > membuf.byteLength) {
			instance.exports.memory.grow((ft_arr.byteLength) / 65536) // 1 page is 64KiB
			window.membuf = instance.exports.memory.buffer;
			free(ptr);
			ptr = malloc(ft_arr.byteLength)
		}

		const ft_buf = new Uint8Array(
			membuf,
			ptr,
			ft_arr.byteLength
		)
		ft_buf.set(ft_arr)

		window.font_buf = ft_buf;

		render_glyph(index, size)
	};
	reader.readAsArrayBuffer(input.files[0]);
}


function checkKey(e) {

	e = e || window.event;

	if (e.keyCode == '38') {
		if (size < 200) {
			render_glyph(index, ++size)
		}
	}
	else if (e.keyCode == '40') {
		if (size > 0) {
			render_glyph(index, --size)
		}
	}
	else if (e.keyCode == '37') {
		if (index > 0) {
			render_glyph(--index, size)
		}
	}
	else if (e.keyCode == '39') {
		render_glyph(++index, size)
	}

}

window.onload = function () {
	window.index = 10
	window.size = 80
	document.onkeydown = checkKey;
	document.getElementById("FileReader").onchange = loadFont
	init();
}
