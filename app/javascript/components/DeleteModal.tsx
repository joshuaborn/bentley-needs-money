import { useState, type SyntheticEvent } from "react"

import { destroy } from '../server';
import type { EditRepaymentFormResponse } from "./EditRepaymentCard";
import type { EditSplitFormResponse } from "./EditSplitCard";

type DeleteModalState = 'open' | 'blocked';
type FormResponse = EditRepaymentFormResponse | EditSplitFormResponse;

interface DeleteModalProps {
    label: string,
    onCancel: (event:SyntheticEvent) => void,
    onDelete: (data:Promise<FormResponse>) => void,
    urlPath: string,
}

export default function DeleteModal(props:DeleteModalProps) {
  const [modalState, setModalState] = useState<DeleteModalState>('open');

  const handleDelete = (event:SyntheticEvent) => {
      event.preventDefault();
      if (modalState === 'open') {
        setModalState('blocked');
        destroy(props.urlPath)
            .then((response) => response.json())
            .then(props.onDelete)
            .catch((error:unknown) => {
                console.log(error);
            });
      }
  };

  return (
      <div className="modal is-active">
        <div className="modal-background" onClick={props.onCancel}></div>
        <div className="modal-card">
          <header className="modal-card-head">
            <p>Are you sure you want to delete this {props.label}?</p>
          </header>
          <footer className="modal-card-foot">
            <div className="buttons">
              <button className={"button is-danger" + (modalState === 'blocked' ? ' is-loading' : '')} onClick={handleDelete}>Delete</button>
              <button className="button" onClick={props.onCancel}>Cancel</button>
            </div>
          </footer>
        </div>
        <button className="modal-close is-large" aria-label="close" onClick={props.onCancel}></button>
      </div>

  );
}