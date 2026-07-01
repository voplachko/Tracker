//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Vsevolod Oplachko on 23.06.2026.
//

import UIKit

enum OnboardingLayout {
    static let horizontalInset = Dimen.x4
    static let dotSize: CGFloat = 6
    static let textToPageControl: CGFloat = 130
    static let pageControlToButton = Dimen.x6      
    static let buttonHeight: CGFloat = 60
    static let buttonBottomInset: CGFloat = 50

    static var titleBottomInset: CGFloat {
        buttonBottomInset + buttonHeight + pageControlToButton + dotSize + textToPageControl
    }
}

final class OnboardingViewController: UIViewController {

    var onFinish: (() -> Void)?

    private lazy var pages: [UIViewController] = [
        OnboardingPageViewController(
            backgroundImage: UIImage(resource: .imgOnboardingFirstScreen),
            title: "Отслеживайте только то, что хотите"
        ),
        OnboardingPageViewController(
            backgroundImage: UIImage(resource: .imgOnboardingSecondScreen),
            title: "Даже если это  не литры воды и йога"
        )
    ]

    private lazy var pageViewController: UIPageViewController = {
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        controller.dataSource = self
        controller.delegate = self
        return controller
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlackDay
        pageControl.pageIndicatorTintColor = .ypBlackDay.withAlphaComponent(0.3)
        pageControl.preferredIndicatorImage = OnboardingViewController.dotImage()
        pageControl.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private lazy var actionButton: PrimaryButton = {
        let button = PrimaryButton(title: "Вот это технологии!")
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    private var currentIndex: Int {
        guard
            let current = pageViewController.viewControllers?.first,
            let index = pages.firstIndex(of: current)
        else { return 0 }
        return index
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addPageViewController()
        if let first = pages.first {
            pageViewController.setViewControllers([first], direction: .forward, animated: false)
        }
        setupOverlay()
    }
}

// MARK: - Layout

private extension OnboardingViewController {
    func addPageViewController() {
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageViewController.view)

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        pageViewController.didMove(toParent: self)
    }

    func setupOverlay() {
        view.addSubview(pageControl)
        view.addSubview(actionButton)

        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: OnboardingLayout.horizontalInset
            ),
            actionButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -OnboardingLayout.horizontalInset
            ),
            actionButton.heightAnchor.constraint(equalToConstant: OnboardingLayout.buttonHeight),
            actionButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -OnboardingLayout.buttonBottomInset
            ),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: OnboardingLayout.dotSize),
            pageControl.bottomAnchor.constraint(
                equalTo: actionButton.topAnchor,
                constant: -OnboardingLayout.pageControlToButton
            )
        ])
    }

    static func dotImage() -> UIImage {
        let size = CGSize(width: OnboardingLayout.dotSize, height: OnboardingLayout.dotSize)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }.withRenderingMode(.alwaysTemplate)
    }
}

// MARK: - Navigation

private extension OnboardingViewController {
    @objc func actionButtonTapped() {
        onFinish?()
    }

    @objc func pageControlValueChanged() {
        let target = pageControl.currentPage
        let direction: UIPageViewController.NavigationDirection =
            target >= currentIndex ? .forward : .reverse
        goToPage(at: target, direction: direction)
    }

    func goToPage(at index: Int, direction: UIPageViewController.NavigationDirection) {
        guard pages.indices.contains(index) else { return }
        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true)
        pageControl.currentPage = index
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        return pages[previousIndex]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        guard nextIndex < pages.count else { return nil }
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed else { return }
        pageControl.currentPage = currentIndex
    }
}
