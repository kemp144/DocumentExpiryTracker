import { createBrowserRouter } from "react-router";
import { Layout } from "./components/Layout";
import { WelcomeScreen } from "./components/WelcomeScreen";
import { HomePage } from "./pages/HomePage";
import { ItemsPage } from "./pages/ItemsPage";
import { ItemDetailPage } from "./pages/ItemDetailPage";
import { AddItemPage } from "./pages/AddItemPage";
import { EditItemPage } from "./pages/EditItemPage";
import { InsightsPage } from "./pages/InsightsPage";
import { SettingsPage } from "./pages/SettingsPage";
import { OnboardingPage } from "./pages/OnboardingPage";
import { PaywallPage } from "./pages/PaywallPage";
import { NotificationPermissionPage } from "./pages/NotificationPermissionPage";
import { DesignSystemPage } from "./pages/DesignSystemPage";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: WelcomeScreen,
  },
  {
    path: "/onboarding",
    Component: OnboardingPage,
  },
  {
    path: "/notifications",
    Component: NotificationPermissionPage,
  },
  {
    path: "/paywall",
    Component: PaywallPage,
  },
  {
    path: "/design-system",
    Component: DesignSystemPage,
  },
  {
    path: "/app",
    Component: Layout,
    children: [
      { index: true, Component: HomePage },
      { path: "items", Component: ItemsPage },
      { path: "item/:id", Component: ItemDetailPage },
      { path: "add", Component: AddItemPage },
      { path: "edit/:id", Component: EditItemPage },
      { path: "insights", Component: InsightsPage },
      { path: "settings", Component: SettingsPage },
    ],
  },
]);