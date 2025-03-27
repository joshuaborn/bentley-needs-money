import type { SyntheticEvent } from 'react';
import { useState } from 'react';

interface FlashNotificationProps {
    kind: string,
    message: string,
};

export default function FlashNotification(props:FlashNotificationProps) {
    const [visibleState, setVisibleState] = useState(true);
    const handleCloseNotification = (event:SyntheticEvent): void => {
        event.preventDefault();
        setVisibleState(false);
    }
    const markup = { __html: props.message };
    let className = props.kind;
    switch (className) {
        case "notice":
            className = "info";
            break;
        case "alert":
            className = "warning";
            break;
        case "error":
            className = "danger";
    }
    if (!visibleState) {
        return null;
    }
    return (
        <div className={"notification is-" + className}>
            <a href="#" className="delete" onClick={handleCloseNotification}></a>
            <div dangerouslySetInnerHTML={markup} />
        </div>
    );
}