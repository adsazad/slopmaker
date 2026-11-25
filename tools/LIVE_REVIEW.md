# LINE 13 live review

From the workspace root, open the review window with:

    .\.venv\Scripts\pythonw.exe tools\live_review.py

Start a Godot render that sends frames to the window:

    .\.venv\Scripts\python.exe tools\live_review.py --render

Use `--sample` for an eight second render. Each run writes a separate AVI under the project's render folder. The window refreshes from Godot's rendered frames and shows the scene timestamp while it renders.

During asset work, publish the current preview and stage:

    .\.venv\Scripts\python.exe tools\live_review.py --publish "House asset review" "Reviewing the Sand3D house lineup." --image assets\houses\houses_preview.png

Saved notes include the stage and scene timestamp. They are stored locally at `godot/line_13/render/.live-review/review-notes.txt`. A note does not send a chat message. The window shows published previews and render frames rather than a desktop or editor screen share.
