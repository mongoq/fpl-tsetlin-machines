import tkinter as tk
import pickle

class PixelPainter:
    def __init__(self, master):
        self.master = master
        self.master.title("Pixel Painter")
        self.canvas_size = 28
        self.pixel_size = 20  # Size of each pixel in pixels
        self.brush_size = 2   # Default brush size set to 2

        # Create a canvas to draw on
        self.canvas = tk.Canvas(master, width=self.canvas_size * self.pixel_size, height=self.canvas_size * self.pixel_size, bg="black")
        self.canvas.pack()

        # 2D list for pixel values
        self.pixels = [[0] * self.canvas_size for _ in range(self.canvas_size)]

        # Draw the initial pixels
        self.draw_grid()

        # Bind mouse events
        self.canvas.bind("<Button-1>", self.paint_white)     # Left-click for white
        self.canvas.bind("<B1-Motion>", self.paint_white)    # Drag left-click for white
        self.canvas.bind("<Button-3>", self.paint_black)     # Right-click for black
        self.canvas.bind("<B3-Motion>", self.paint_black)    # Drag right-click for black
        self.canvas.bind("<ButtonRelease-1>", self.release)  # Handle mouse button release
        self.canvas.bind("<ButtonRelease-3>", self.release)  # Handle mouse button release

        # Entry field for the filename
        tk.Label(master, text="Filename (without extension):").pack(side="left")
        self.filename_entry = tk.Entry(master)
        self.filename_entry.pack(side="left")
        self.filename_entry.insert(0, "pixel_data")  # Default filename without extension

        # Entry field for brush size
        tk.Label(master, text="Brush Size (1-5):").pack(side="left")
        self.brush_size_entry = tk.Entry(master, width=5)
        self.brush_size_entry.pack(side="left")
        self.brush_size_entry.insert(0, "2")  # Default brush size set to 2

        # Save and Reset buttons side by side in a frame
        button_frame = tk.Frame(master)
        button_frame.pack(side="left", padx=10)
        save_button = tk.Button(button_frame, text="Save as .h", command=self.save)
        save_button.pack(side="left")

        save_pickle_button = tk.Button(button_frame, text="Save as .pkl", command=self.save_as_pickle)
        save_pickle_button.pack(side="left")

        reset_button = tk.Button(button_frame, text="Reset", command=self.reset_canvas)
        reset_button.pack(side="left")

    def draw_grid(self):
        """Initializes or redraws the pixel grid on the canvas."""
        for i in range(self.canvas_size):
            for j in range(self.canvas_size):
                x1 = j * self.pixel_size
                y1 = i * self.pixel_size
                x2 = x1 + self.pixel_size
                y2 = y1 + self.pixel_size
                self.canvas.create_rectangle(x1, y1, x2, y2, fill="black", outline="gray")

    def paint_white(self, event):
        """Paints white pixels when left mouse button is held (invert of black)."""
        self.paint(event, color="white", value=1)

    def paint_black(self, event):
        """Paints black pixels (erase) when right mouse button is held (invert of white)."""
        self.paint(event, color="black", value=0)

    def paint(self, event, color, value):
        """Handles painting on the canvas with specified color and value."""
        x = event.x // self.pixel_size
        y = event.y // self.pixel_size

        # Update brush size
        try:
            self.brush_size = int(self.brush_size_entry.get())
            self.brush_size = max(1, min(self.brush_size, 5))  # Limit brush size to 1-5
        except ValueError:
            self.brush_size = 2  # Default value set to 2 on invalid input

        # Paint pixels within the brush size range
        for i in range(-self.brush_size + 1, self.brush_size):
            for j in range(-self.brush_size + 1, self.brush_size):
                if abs(i) + abs(j) < self.brush_size:  # Round brush
                    px = x + i
                    py = y + j
                    if 0 <= px < self.canvas_size and 0 <= py < self.canvas_size:
                        self.pixels[py][px] = value
                        self.canvas.create_rectangle(px * self.pixel_size, py * self.pixel_size,
                                                      (px + 1) * self.pixel_size, (py + 1) * self.pixel_size,
                                                      fill=color, outline="gray")

    def reset_canvas(self):
        """Clears the canvas and resets all pixels to black."""
        self.pixels = [[0] * self.canvas_size for _ in range(self.canvas_size)]
        self.draw_grid()  # Redraw the grid to clear the canvas

    def release(self, event):
        """Can be used for additional actions after the mouse button is released."""
        pass

    def save(self):
        """Saves the pixel data to a .h file with the specified filename and formatting."""
        filename = self.filename_entry.get() + ".h"  # Add .h extension
        with open(filename, "w") as hfile:
            hfile.write("#include <stdint.h>\n\n")
            hfile.write("uint8_t data[] = {\n")
            # Write the pixel values in the desired format with line breaks after every 28 pixels
            for i in range(self.canvas_size):
                line = ", ".join(str(self.pixels[i][j]) for j in range(self.canvas_size))
                if i < self.canvas_size - 1:  # Add a comma if it's not the last line
                    hfile.write(f"    {line},\n")
                else:
                    hfile.write(f"    {line}\n")  # No comma for the last line
            hfile.write("};\n")
        print(f"Pixel values saved as {filename}")  # Show .h extension in console

    def save_as_pickle(self):
        """Saves the pixel data to a .pkl file for loading in Python."""
        filename = self.filename_entry.get() + ".pkl"  # Add .pkl extension
        with open(filename, "wb") as pfile:
            pickle.dump(self.pixels, pfile)
        print(f"Pixel values saved as {filename}")  # Show .pkl extension in console

if __name__ == "__main__":
    root = tk.Tk()
    pixel_painter = PixelPainter(root)
    root.mainloop()

