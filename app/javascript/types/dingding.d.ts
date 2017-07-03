declare namespace Dingding {

    class Dingding {

        device: Device;
    }

    class Device {

        notification: Notification;
    }

    interface Notice {
        title?: string,
        message?: string,
        text?: string,
        onSuccess?: () => any
    }

    class Notification {

        alert(notice: Notice): void;

        toast(notice: Notice): void;
    }
}

declare const dd: Dingding.Dingding;

declare module 'dingding' {
    export = dd;
}