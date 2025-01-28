import type { SyntheticEvent } from "react"

interface DeleteModalProps {
    label: string,
    onCancel: (event:SyntheticEvent) => void,
    onDelete: (event:SyntheticEvent) => void,
}

export default function DeleteModal(props:DeleteModalProps) {
    return (
        <div className="modal is-active">
          <div className="modal-background" onClick={props.onCancel}></div>
          <div className="modal-card">
            <header className="modal-card-head">
              <p>Are you sure you want to delete this {props.label}?</p>
            </header>
            <footer className="modal-card-foot">
              <div className="buttons">
                <button className="button is-danger" onClick={props.onDelete}>Delete</button>
                <button className="button" onClick={props.onCancel}>Cancel</button>
              </div>
            </footer>
          </div>
          <button className="modal-close is-large" aria-label="close" onClick={props.onCancel}></button>
        </div>

    );
}